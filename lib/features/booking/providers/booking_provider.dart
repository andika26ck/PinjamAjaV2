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

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(BookingRepositoryRef ref) =>
    SupabaseBookingRepository(ref.watch(supabaseClientProvider));

/// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
@riverpod
Future<Item> bookingItem(BookingItemRef ref, String itemId) =>
    ref.watch(bookingRepositoryProvider).fetchItem(itemId);

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
        AppConstants.bookingStatusPending,
        AppConstants.bookingStatusConfirmed,
        AppConstants.bookingStatusActive,
      };
      final existing = await repo.fetchItemBookings(item.id);
      for (final b in existing) {
        if (!occupied.contains(b.status)) continue;
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
        'total_day': days,
        'price_per_day': item.pricePerDay,
        'deposit_amount': item.depositAmount,
        'platform_fee': fee,
        'total_price': total,
        'status': AppConstants.bookingStatusPending,
        'payment_status': AppConstants.paymentStatusUnpaid,
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
  Future<bool> cancelBooking(String id, {String? reason}) =>
      _runBool(() => ref.read(bookingRepositoryProvider).updateStatus(
            id: id,
            status: AppConstants.bookingStatusCancelled,
            cancellationReason: reason,
          ));

  /// Owner menerima permintaan -> confirmed.
  Future<bool> confirmBooking(String id) => _runBool(() => ref
      .read(bookingRepositoryProvider)
      .updateStatus(id: id, status: AppConstants.bookingStatusConfirmed));

  /// Owner menolak -> cancelled + alasan.
  Future<bool> rejectBooking(String id, {required String reason}) =>
      _runBool(() => ref.read(bookingRepositoryProvider).updateStatus(
            id: id,
            status: AppConstants.bookingStatusCancelled,
            cancellationReason: reason,
          ));

  /// Owner memulai sewa -> active.
  Future<bool> startRental(String id) => _runBool(() => ref
      .read(bookingRepositoryProvider)
      .updateStatus(id: id, status: AppConstants.bookingStatusActive));

  /// Owner menandai barang dikembalikan -> completed.
  Future<bool> markReturned(String id) => _runBool(() => ref
      .read(bookingRepositoryProvider)
      .updateStatus(id: id, status: AppConstants.bookingStatusCompleted));

  /// Kirim ulasan untuk booking yang sudah selesai.
  Future<bool> submitReview({
    required String bookingId,
    required String itemId,
    required double rating,
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