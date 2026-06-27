import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/payment_model.dart';
import '../data/models/payment_request_model.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/supabase_payment_repository.dart';

part 'payment_provider.g.dart';

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(PaymentRepositoryRef ref) =>
    SupabasePaymentRepository(ref.watch(supabaseClientProvider));

/// Trigger pembuatan Snap token untuk sebuah booking.
@riverpod
Future<PaymentRequestModel> createPayment(
    CreatePaymentRef ref, String bookingId) {
  return ref.watch(paymentRepositoryProvider).createPayment(bookingId);
}

/// Status pembayaran realtime (auto-update via Supabase Realtime).
@riverpod
Stream<PaymentModel?> paymentByBooking(
    PaymentByBookingRef ref, String bookingId) {
  return ref.watch(paymentRepositoryProvider).watchPayment(bookingId);
}

/// Aksi refund deposit oleh owner.
@riverpod
class RefundController extends _$RefundController {
  @override
  FutureOr<void> build() {}

  Future<bool> requestRefund(String bookingId, {String? reason}) async {
    state = const AsyncLoading();
    try {
      await ref.read(paymentRepositoryProvider).requestRefund(bookingId, reason: reason);
      ref.invalidate(paymentByBookingProvider(bookingId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

/// Ringkasan & daftar payout untuk owner yang login.
@riverpod
Future<List<Map<String, dynamic>>> ownerPayouts(OwnerPayoutsRef ref) async {
  final client = ref.watch(supabaseClientProvider);
  final uid = client.auth.currentUser!.id;
  final rows = await client
      .from('payouts')
      .select('*, booking:bookings(id, item:items(title)), renter:profiles!payouts_owner_id_fkey(name)')
      .eq('owner_id', uid)
      .order('created_at', ascending: false);
  return (rows as List).cast<Map<String, dynamic>>();
}