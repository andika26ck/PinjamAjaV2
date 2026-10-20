import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/manual_payment_model.dart';
import '../models/payment_account_model.dart';
import 'manual_payment_repository.dart';

class SupabaseManualPaymentRepository implements ManualPaymentRepository {
  final SupabaseClient _client;
  SupabaseManualPaymentRepository(this._client);

  static const _bucket = 'payment-proofs';

  Map<String, dynamic> _one(dynamic data) => data is List
      ? data.first as Map<String, dynamic>
      : data as Map<String, dynamic>;

  @override
  Future<List<PaymentAccountModel>> fetchActiveAccounts() async {
    final rows = await _client
        .from('payment_accounts')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    return (rows as List)
        .map((e) => PaymentAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ManualPaymentModel> createOrGetManualPayment(String bookingId) async {
    final data = await _client
        .rpc('create_manual_payment', params: {'p_booking_id': bookingId});
    return ManualPaymentModel.fromJson(_one(data));
  }

  @override
  Future<ManualPaymentModel?> getPaymentByBooking(String bookingId) async {
    final rows = await _client
        .from('payments')
        .select()
        .eq('booking_id', bookingId)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return ManualPaymentModel.fromJson(list.first as Map<String, dynamic>);
  }

  @override
  Stream<ManualPaymentModel?> watchPayment(String bookingId) {
    return _client
        .from('payments')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .map((rows) =>
            rows.isEmpty ? null : ManualPaymentModel.fromJson(rows.first));
  }

  @override
  Future<String> uploadProof({
    required String bookingId,
    required String filePath,
  }) async {
    final uid = _client.auth.currentUser!.id;
    final ext = filePath.contains('.') ? filePath.split('.').last : 'jpg';
    final objectPath =
        '$uid/$bookingId-${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).upload(
          objectPath,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );
    return objectPath;
  }

  @override
  Future<void> submitProof({
    required String bookingId,
    required String proofPath,
    required String senderName,
    required String channel,
    required String accountId,
  }) async {
    await _client.rpc('submit_manual_payment_proof', params: {
      'p_booking_id': bookingId,
      'p_proof_url': proofPath,
      'p_sender_name': senderName,
      'p_channel': channel,
      'p_account_id': accountId,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchManualQueue({String? status}) async {
    var filter = _client
        .from('payments')
        .select(
            '*, booking:bookings(id, start_date, end_date, item:items(title))')
        .eq('payment_method', 'manual')
        .not('proof_url', 'is', null);
    if (status != null && status.isNotEmpty) {
      filter = filter.eq('status', status);
    }
    final rows = await filter.order('proof_submitted_at', ascending: true);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<String?> signedProofUrl(String path) async {
    try {
      return await _client.storage.from(_bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> verifyManualPayment({
    required String paymentId,
    required bool approve,
    String? note,
  }) async {
    await _client.rpc('admin_verify_manual_payment', params: {
      'p_payment_id': paymentId,
      'p_approve': approve,
      'p_note': note,
    });
  }
}