import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_exception.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/booking_repository.dart';
import '../data/supabase_booking_repository.dart';
import 'booking_detail_provider.dart';
import 'booking_list_provider.dart';

part 'booking_provider.g.dart';

/// Hasil perhitungan denda keterlambatan pengembalian.
class LateFeeResult {
  final int lateDays;
  final int lateFee;
  final int depositRefund; // sisa deposit yang dikembalikan ke penyewa
  final int outstanding; // kekurangan denda yang masih ditagih ke penyewa
  final String status; // none | unpaid | paid
  const LateFeeResult({
    required this.lateDays,
    required this.lateFee,
    required this.depositRefund,
    required this.outstanding,
    required this.status,
  });
}

/// Hitung denda telat: toleransi sampai jam 12 siang H+1 dari tanggal selesai,
/// lewat itu denda = (hari telat) x tarif sewa harian x lateFeeRatePerDay.
/// Denda dipotong dari deposit dulu; kekurangannya jadi tagihan penyewa.
LateFeeResult computeLateFee({
  required DateTime? endDate,
  required int pricePerDay,
  required int depositAmount,
  required DateTime returnedAt,
}) {
  if (endDate == null) {
    return LateFeeResult(
      lateDays: 0,
      lateFee: 0,
      depositRefund: depositAmount,
      outstanding: 0,
      status: AppConstants.lateFeeStatusNone,
    );
  }
  final base = DateTime(endDate.year, endDate.month, endDate.day);
  final deadline = base
      .add(const Duration(days: 1))
      .add(const Duration(hours: AppConstants.lateGraceUntilHour));

  var lateDays = 0;
  if (returnedAt.isAfter(deadline)) {
    final diff = returnedAt.difference(deadline);
    lateDays = (diff.inSeconds / 86400).ceil();
    if (lateDays < 1) lateDays = 1;
  }

  final lateFee =
      (lateDays * pricePerDay * AppConstants.lateFeeRatePerDay).round();
  final covered = lateFee < depositAmount ? lateFee : depositAmount;
  final depositRefund = depositAmount - covered;
  final outstanding = lateFee - covered;
  final status = lateFee == 0
      ? AppConstants.lateFeeStatusNone
      : (outstanding > 0
          ? AppConstants.lateFeeStatusUnpaid
          : AppConstants.lateFeeStatusPaid);

  return LateFeeResult(
    lateDays: lateDays,
    lateFee: lateFee,
    depositRefund: depositRefund,
    outstanding: outstanding,
    status: status,
  );
}

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(BookingRepositoryRef ref) =>
    SupabaseBookingRepository(ref.watch(supabaseClientProvider));

/// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
@riverpod
Future<Item> bookingItem(BookingItemRef ref, String itemId) =>
    ref.watch(bookingRepositoryProvider).fetchItem(itemId);

/// Kumpulan tanggal yang sudah terisi booking penyewa lain untuk satu item.
/// Dipakai kalender booking agar tanggal terpakai langsung dinonaktifkan,
/// jadi penyewa tak perlu menebak-nebak tanggal yang masih kosong.
@riverpod
Future<Set<DateTime>> itemOccupiedDates(
    ItemOccupiedDatesRef ref, String itemId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final bookings = await repo.fetchItemBookings(itemId);
  const occupied = {
    AppConstants.bookingStatusAwaitingPayment,
    AppConstants.bookingStatusPending,
    AppConstants.bookingStatusConfirmed,
    AppConstants.bookingStatusActive,
  };
  final now = DateTime.now();
  final result = <DateTime>{};
  for (final b in bookings) {
    if (!occupied.contains(b.status)) continue;
    // 'awaiting_payment' yang sudah lewat tenggat tidak lagi mengunci tanggal.
    if (b.status == AppConstants.bookingStatusAwaitingPayment &&
        b.expiresAt != null &&
        b.expiresAt!.isBefore(now)) {
      continue;
    }
    final s = b.startDate, e = b.endDate;
    if (s == null || e == null) continue;
    final start = DateTime(s.year, s.month, s.day);
    final end = DateTime(e.year, e.month, e.day);
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      result.add(d);
    }
  }
  return result;
}

/// Aksi tulis booking. State `AsyncValue<void>` untuk loading & error.
@riverpod
class BookingController extends _$BookingController {
  @override
  FutureOr<void> build() {}

  String _uid() {
    final id = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
    }
    return id;
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Buat booking. Validasi blocked_dates & tumpang tindih sebelum submit.
  Future<Booking?> createBooking({
    required Item item,
    required DateTime start,
    required DateTime end,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final renterId = _uid();

      // 0) Pemilik tidak boleh menyewa barangnya sendiri.
      if (renterId == item.ownerId) {
        throw const AppException(
            'Kamu tidak bisa menyewa barang milikmu sendiri.');
      }

      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day);

      // 1) Tidak boleh menabrak blocked_dates milik item.
      final blocked = {
        for (final d in item.blockedDates) DateTime(d.year, d.month, d.day),
      };
      for (var d = s; !d.isAfter(e); d = d.add(const Duration(days: 1))) {
        if (blocked.contains(d)) {
          throw const AppException(
              'Ada tanggal yang tidak tersedia di rentang yang kamu pilih.');
        }
      }

      // 2) Tidak boleh tumpang tindih dengan booking lain yang masih berjalan.
      const occupied = {
        AppConstants.bookingStatusAwaitingPayment,
        AppConstants.bookingStatusPending,
        AppConstants.bookingStatusConfirmed,
        AppConstants.bookingStatusActive,
      };
      final existing = await repo.fetchItemBookings(item.id);
      for (final b in existing) {
        if (!occupied.contains(b.status)) continue;
        // Booking 'awaiting_payment' yang sudah lewat deadline tidak mengunci tanggal.
        if (b.status == AppConstants.bookingStatusAwaitingPayment &&
            b.expiresAt != null &&
            b.expiresAt!.isBefore(DateTime.now())) {
          continue;
        }
        final bs = b.startDate, be = b.endDate;
        if (bs == null || be == null) continue;
        final overlap = !s.isAfter(be) && !e.isBefore(bs);
        if (overlap) {
          throw const AppException(
              'Barang sudah dipesan pada sebagian tanggal tersebut.');
        }
      }

      final days = e.difference(s).inDays + 1;
      final subtotal = item.pricePerDay * days;
      final fee = (subtotal * AppConstants.platformFeeRate).round();
      final total = subtotal + fee + item.depositAmount;

      final booking = await repo.createBooking({
        'item_id': item.id,
        'renter_id': renterId,
        'owner_id': item.ownerId,
        'start_date': _fmtDate(s),
        'end_date': _fmtDate(e),
        'price_per_day': item.pricePerDay,
        'deposit_amount': item.depositAmount,
        'platform_fee': fee,
        'total_price': total,
        'status': AppConstants.bookingStatusAwaitingPayment,
        'payment_status': AppConstants.paymentStatusUnpaid,
        'expires_at': DateTime.now()
            .toUtc()
            .add(const Duration(hours: 24))
            .toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      });

      _invalidateLists();
      state = const AsyncData(null);
      return booking;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return null;
    }
  }

  /// Bayar (simulasi): payment_status -> paid, status tetap pending.
  Future<Booking?> pay(String bookingId) =>
      _run(() => ref.read(bookingRepositoryProvider).markPaid(bookingId));

  /// Renter membatalkan booking.
  Future<bool> cancelBooking(String id,
          {String? reason, bool refund = false}) =>
      _runBool(() => ref.read(bookingRepositoryProvider).updateStatus(
            id: id,
            status: AppConstants.bookingStatusCancelled,
            cancellationReason: reason,
            refundStatus: refund ? AppConstants.refundStatusRefunded : null,
          ));

  /// Owner menerima permintaan -> confirmed (eksklusif via RPC server).
  /// Bila ada booking lain yang bentrok & masih menunggu, otomatis
  /// dibatalkan + dana dikembalikan.
  Future<bool> confirmBooking(String id) =>
      _runBool(() => ref.read(bookingRepositoryProvider).confirmBooking(id));

  /// Owner menolak -> cancelled + alasan.
  Future<bool> rejectBooking(String id,
          {required String reason, bool refund = false}) =>
      _runBool(() => ref.read(bookingRepositoryProvider).updateStatus(
            id: id,
            status: AppConstants.bookingStatusCancelled,
            cancellationReason: reason,
            refundStatus: refund ? AppConstants.refundStatusRefunded : null,
          ));

  /// Owner memulai sewa -> active + catat started_at (tanggal & jam).
  Future<bool> startRental(String id) =>
      _runBool(() => ref.read(bookingRepositoryProvider).markStarted(id));

  /// Owner menandai barang dikembalikan -> completed.
  /// Sekaligus hitung denda keterlambatan & potong dari deposit.
  Future<bool> markReturned(Booking booking) => _runBool(() {
        final now = DateTime.now();
        final f = computeLateFee(
          endDate: booking.endDate,
          pricePerDay: booking.pricePerDay,
          depositAmount: booking.depositAmount,
          returnedAt: now,
        );
        return ref.read(bookingRepositoryProvider).markReturned(
              id: booking.id,
              returnedAt: now,
              lateDays: f.lateDays,
              lateFee: f.lateFee,
              depositRefund: f.depositRefund,
              lateFeeStatus: f.status,
            );
      });

  /// Penyewa membayar kekurangan denda (simulasi) -> late_fee_status: paid.
  Future<bool> payLateFee(String id) =>
      _runBool(() => ref.read(bookingRepositoryProvider).payLateFee(id));

  /// Kirim ulasan untuk booking yang sudah selesai.
  Future<bool> submitReview({
    required String bookingId,
    required String itemId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepositoryProvider).submitReview({
        'booking_id': bookingId,
        'item_id': itemId,
        'reviewer_id': _uid(),
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      });
      ref.invalidate(bookingDetailProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  Future<Booking?> _run(Future<Booking> Function() action) async {
    state = const AsyncLoading();
    try {
      final b = await action();
      _invalidateLists();
      state = const AsyncData(null);
      return b;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return null;
    }
  }

  Future<bool> _runBool(Future<Booking> Function() action) async {
    final b = await _run(action);
    return b != null;
  }

  void _invalidateLists() {
    ref.invalidate(renterBookingsProvider);
    ref.invalidate(ownerBookingsProvider);
    ref.invalidate(bookingDetailProvider);
  }
}