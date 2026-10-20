import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/deposit_refund_model.dart';
import 'manual_refund_repository.dart';

class SupabaseManualRefundRepository implements ManualRefundRepository {
  final SupabaseClient _client;
  SupabaseManualRefundRepository(this._client);

  static const _bucket = 'payout-proofs';

  @override
  Future<List<DepositRefundModel>> fetchRefundQueue({String? status}) async {
    var filter = _client
        .from('payments')
        .select(
            '*, renter:profiles!payments_renter_id_fkey(name, payout_bank_name, payout_account_number, payout_account_name), booking:bookings(status, item:items(title))')
        .gt('deposit_amount', 0);
    if (status != null && status.isNotEmpty) {
      filter = filter.eq('status', status);
    }
    final rows = await filter.order('created_at', ascending: false);
    return (rows as List)
        .map((e) => DepositRefundModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> uploadRefundProof({
    required String renterId,
    required String paymentId,
    required String filePath,
  }) async {
    final ext = filePath.contains('.') ? filePath.split('.').last : 'jpg';
    final objectPath =
        '$renterId/refund-$paymentId-${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).upload(
          objectPath,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );
    return objectPath;
  }

  @override
  Future<String?> signedRefundProofUrl(String path) async {
    try {
      return await _client.storage.from(_bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> refundDeposit({
    required String paymentId,
    String? proofPath,
    String? note,
  }) async {
    await _client.rpc('admin_refund_deposit_manual', params: {
      'p_payment_id': paymentId,
      'p_proof_url': proofPath,
      'p_note': note,
    });
  }
}