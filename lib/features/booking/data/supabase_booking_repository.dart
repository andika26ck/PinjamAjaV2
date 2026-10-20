import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';
import 'booking_repository.dart';

class SupabaseBookingRepository implements BookingRepository {
  final SupabaseClient _client;
  SupabaseBookingRepository(this._client);

  List<Map<String, dynamic>> _rows(dynamic data) =>
      (data as List).cast<Map<String, dynamic>>();

  @override
  Future<Booking> createBooking(Map<String, dynamic> payload) async {
    final data =
        await _client.from('bookings').insert(payload).select().single();
    return Booking.fromJson(data);
  }

  @override
  Future<Booking> fetchBookingById(String id) async {
    final data =
        await _client.from('bookings').select().eq('id', id).single();
    return Booking.fromJson(data);
  }

  @override
  Future<Item> fetchItem(String itemId) async {
    final data =
        await _client.from('items').select().eq('id', itemId).single();
    return Item.fromJson(data);
  }

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data == null ? null : UserProfile.fromJson(data);
  }

  @override
  Future<List<Booking>> fetchItemBookings(String itemId) async {
    final rows = _rows(
        await _client.from('bookings').select().eq('item_id', itemId));
    return rows.map(Booking.fromJson).toList();
  }

  @override
  Future<Booking?> fetchLatestBookingBetween({
    required String itemId,
    required String userA,
    required String userB,
  }) async {
    final data = await _client
        .from('bookings')
        .select()
        .eq('item_id', itemId)
        .or('and(renter_id.eq.$userA,owner_id.eq.$userB),'
            'and(renter_id.eq.$userB,owner_id.eq.$userA)')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data == null ? null : Booking.fromJson(data);
  }

  @override
  Stream<List<Booking>> watchRenterBookings(String renterId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('renter_id', renterId)
        .order('created_at')
        .map((rows) => rows.map(Booking.fromJson).toList());
  }

  @override
  Stream<List<Booking>> watchOwnerBookings(String ownerId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId)
        .order('created_at')
        .map((rows) => rows.map(Booking.fromJson).toList());
  }

  @override
  Future<List<BookingView>> attachItems(List<Booking> bookings) async {
    if (bookings.isEmpty) return const [];
    final ids = bookings.map((b) => b.itemId).toSet().toList();
    final rows =
        _rows(await _client.from('items').select().inFilter('id', ids));
    final byId = {
      for (final r in rows) r['id'] as String: Item.fromJson(r),
    };
    return bookings
        .map((b) => BookingView(booking: b, item: byId[b.itemId]))
        .toList();
  }

  @override
  Future<Booking> updateStatus({
    required String id,
    required String status,
    String? cancellationReason,
    String? refundStatus,
  }) async {
    final payload = <String, dynamic>{'status': status};
    if (cancellationReason != null) {
      payload['cancellation_reason'] = cancellationReason;
    }
    if (refundStatus != null) {
      payload['refund_status'] = refundStatus;
      if (refundStatus == AppConstants.refundStatusRefunded) {
        payload['refunded_at'] = DateTime.now().toUtc().toIso8601String();
      }
    }
    final data = await _client
        .from('bookings')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return Booking.fromJson(data);
  }

  @override
  Future<Booking> confirmBooking(String id) async {
    // Panggil RPC server: penjaga eksklusif + auto-refund bentrok (atomic).
    final data =
        await _client.rpc('confirm_booking', params: {'p_booking_id': id});
    final json = data is List
        ? (data.first as Map<String, dynamic>)
        : data as Map<String, dynamic>;
    return Booking.fromJson(json);
  }

  @override
  Future<Booking> markPaid(String id) async {
    final data = await _client
        .from('bookings')
        .update({
          'payment_status': AppConstants.paymentStatusPaid,
          'status': AppConstants.bookingStatusPending,
          'expires_at': null,
          // Pemilik wajib konfirmasi sebelum tenggat; lewat itu booking
          // otomatis dibatalkan & dana dikembalikan (lihat pg_cron).
          'confirmation_deadline': DateTime.now()
              .toUtc()
              .add(const Duration(
                  hours: AppConstants.ownerConfirmDeadlineHours))
              .toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return Booking.fromJson(data);
  }

  @override
  Future<Booking> markStarted(String id) async {
    final data = await _client
        .from('bookings')
        .update({
          'status': AppConstants.bookingStatusActive,
          'started_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return Booking.fromJson(data);
  }

  @override
  Future<Booking> markReturned({
    required String id,
    required DateTime returnedAt,
    required int lateDays,
    required int lateFee,
    required int depositRefund,
    required String lateFeeStatus,
  }) async {
    final data = await _client
        .from('bookings')
        .update({
          'status': AppConstants.bookingStatusCompleted,
          'returned_at': returnedAt.toUtc().toIso8601String(),
          'late_days': lateDays,
          'late_fee': lateFee,
          'deposit_refund': depositRefund,
          'late_fee_status': lateFeeStatus,
        })
        .eq('id', id)
        .select()
        .single();
    return Booking.fromJson(data);
  }

  @override
  Future<Booking> payLateFee(String id) async {
    final data = await _client
        .from('bookings')
        .update({'late_fee_status': AppConstants.lateFeeStatusPaid})
        .eq('id', id)
        .select()
        .single();
    return Booking.fromJson(data);
  }

  @override
  Future<bool> hasReview({
    required String bookingId,
    required String reviewerId,
  }) async {
    final data = await _client
        .from('reviews')
        .select('id')
        .eq('booking_id', bookingId)
        .eq('reviewer_id', reviewerId)
        .maybeSingle();
    return data != null;
  }

  @override
  Future<void> submitReview(Map<String, dynamic> payload) async {
    await _client.from('reviews').insert(payload);
  }
}