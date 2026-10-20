import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payout_account.dart';
import '../models/payout_model.dart';
import 'manual_payout_repository.dart';

class SupabaseManualPayoutRepository implements ManualPayoutRepository {
  final SupabaseClient _client;
  SupabaseManualPayoutRepository(this._client);

  static const _bucket = 'payout-proofs';

  @override
  Future<PayoutAccount> getMyPayoutAccount() async {
    final uid = _client.auth.currentUser!.id;
    final row = await _client
        .from('profiles')
        .select('payout_bank_name, payout_account_number, payout_account_name')
        .eq('id', uid)
        .single();
    return PayoutAccount.fromJson(row);
  }

  @override
  Future<void> updateMyPayoutAccount({
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('profiles').update({
      'payout_bank_name': bankName,
      'payout_account_number': accountNumber,
      'payout_account_name': accountName,
    }).eq('id', uid);
  }

  @override
  Future<List<ManualPayoutModel>> fetchPayoutQueue({String? status}) async {
    var filter = _client.from('payouts').select(
        '*, owner:profiles!payouts_owner_id_fkey(name, payout_bank_name, payout_account_number, payout_account_name), booking:bookings(id, item:items(title))');
    if (status != null && status.isNotEmpty) {
      filter = filter.eq('status', status);
    }
    final rows = await filter.order('scheduled_at', ascending: true);
    return (rows as List)
        .map((e) => ManualPayoutModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> uploadPayoutProof({
    required String ownerId,
    required String payoutId,
    required String filePath,
  }) async {
    final ext = filePath.contains('.') ? filePath.split('.').last : 'jpg';
    final objectPath =
        '$ownerId/$payoutId-${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).upload(
          objectPath,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );
    return objectPath;
  }

  @override
  Future<String?> signedPayoutProofUrl(String path) async {
    try {
      return await _client.storage.from(_bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> completePayout({
    required String payoutId,
    String? proofPath,
    String? note,
  }) async {
    await _client.rpc('admin_complete_payout', params: {
      'p_payout_id': payoutId,
      'p_proof_url': proofPath,
      'p_note': note,
    });
  }
}