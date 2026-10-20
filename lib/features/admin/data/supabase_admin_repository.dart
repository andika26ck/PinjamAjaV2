import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/admin_stats.dart';
import '../../../data/models/dispute.dart';
import '../../../data/models/item.dart';
import '../../../data/models/payout.dart';
import '../../../data/models/report.dart';
import '../../../data/models/user_profile.dart';
import 'admin_repository.dart';

class SupabaseAdminRepository implements AdminRepository {
  final SupabaseClient _client;
  SupabaseAdminRepository(this._client);

  List<Map<String, dynamic>> _rows(dynamic data) =>
      (data as List).cast<Map<String, dynamic>>();

  /// RPC yang `returns <table>` bisa balik 1 objek atau list 1 elemen.
  Map<String, dynamic> _one(dynamic data) => data is List
      ? data.first as Map<String, dynamic>
      : data as Map<String, dynamic>;

  String _nowUtc() => DateTime.now().toUtc().toIso8601String();

  @override
  Future<AdminDashboardStats> fetchDashboardStats() async {
    final data = await _client.rpc('admin_dashboard_stats');
    return AdminDashboardStats.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<UserProfile>> fetchUsers(
      {String? query, bool? suspendedOnly}) async {
    var filter = _client.from('profiles').select();
    final term = query?.trim() ?? '';
    if (term.isNotEmpty) {
      filter = filter.or('name.ilike.%$term%,phone.ilike.%$term%');
    }
    if (suspendedOnly == true) {
      filter = filter.eq('is_suspended', true);
    }
    final rows = _rows(await filter.order('created_at', ascending: false));
    return rows.map(UserProfile.fromJson).toList();
  }

  @override
  Future<List<UserProfile>> fetchKycQueue() async {
    final rows = _rows(await _client
        .from('profiles')
        .select()
        .eq('kyc_status', 'pending')
        .order('kyc_submitted_at', ascending: true));
    return rows.map(UserProfile.fromJson).toList();
  }

  @override
  Future<UserProfile> setSuspended({
    required String userId,
    required bool suspended,
    String? reason,
  }) async {
    final data = await _client.rpc('admin_set_suspended', params: {
      'p_user_id': userId,
      'p_suspended': suspended,
      'p_reason': reason,
    });
    return UserProfile.fromJson(_one(data));
  }

  @override
  Future<UserProfile> reviewKyc({
    required String userId,
    required bool approve,
    String? rejectReason,
  }) async {
    final data = await _client.rpc('admin_review_kyc', params: {
      'p_user_id': userId,
      'p_approve': approve,
      'p_reason': rejectReason,
    });
    return UserProfile.fromJson(_one(data));
  }

  @override
  Future<List<Item>> fetchItemsForModeration({String? moderationStatus}) async {
    var filter = _client.from('items').select();
    if (moderationStatus != null && moderationStatus.isNotEmpty) {
      filter = filter.eq('moderation_status', moderationStatus);
    }
    final rows = _rows(await filter.order('created_at', ascending: false));
    return rows.map(Item.fromJson).toList();
  }

  @override
  Future<Item> moderateItem({
    required String itemId,
    required String status,
    String? note,
  }) async {
    final data = await _client.rpc('admin_moderate_item', params: {
      'p_item_id': itemId,
      'p_status': status,
      'p_note': note,
    });
    return Item.fromJson(_one(data));
  }

  @override
  Future<List<Report>> fetchReports({String? status}) async {
    var filter = _client.from('reports').select();
    if (status != null && status.isNotEmpty) {
      filter = filter.eq('status', status);
    }
    final rows = _rows(await filter.order('created_at', ascending: false));
    return rows.map(Report.fromJson).toList();
  }

  @override
  Future<Report> updateReportStatus({
    required String reportId,
    required String status,
    String? adminNote,
  }) async {
    final payload = <String, dynamic>{'status': status};
    if (adminNote != null) payload['admin_note'] = adminNote;
    if (status == 'resolved' || status == 'dismissed') {
      payload['resolved_by'] = _client.auth.currentUser?.id;
      payload['resolved_at'] = _nowUtc();
    }
    final data = await _client
        .from('reports')
        .update(payload)
        .eq('id', reportId)
        .select()
        .single();
    return Report.fromJson(data);
  }

  @override
  Future<List<Dispute>> fetchDisputes({String? status}) async {
    var filter = _client.from('disputes').select();
    if (status != null && status.isNotEmpty) {
      filter = filter.eq('status', status);
    }
    final rows = _rows(await filter.order('created_at', ascending: false));
    return rows.map(Dispute.fromJson).toList();
  }

  @override
  Future<Dispute> resolveDispute({
    required String disputeId,
    required String resolution,
    String? note,
    num? refundAmount,
  }) async {
    final data = await _client.rpc('admin_resolve_dispute', params: {
      'p_dispute_id': disputeId,
      'p_resolution': resolution,
      'p_note': note,
      'p_refund_amount': refundAmount,
    });
    return Dispute.fromJson(_one(data));
  }

  @override
  Future<List<Payout>> fetchPayouts({String? status}) async {
    var filter = _client.from('payouts').select();
    if (status != null && status.isNotEmpty) {
      filter = filter.eq('status', status);
    }
    final rows = _rows(await filter.order('scheduled_at', ascending: false));
    return rows.map(Payout.fromJson).toList();
  }

  @override
  Future<Payout> releasePayout(String payoutId) async {
    final data = await _client
        .rpc('admin_release_payout', params: {'p_payout_id': payoutId});
    return Payout.fromJson(_one(data));
  }

  @override
  Future<Map<String, dynamic>> fetchConfig() async {
    final rows = _rows(await _client.from('app_config').select());
    return {for (final r in rows) r['key'] as String: r['value']};
  }

  @override
  Future<void> updateConfig(
      {required String key, required Object? value}) async {
    await _client.from('app_config').update({
      'value': value,
      'updated_at': _nowUtc(),
      'updated_by': _client.auth.currentUser?.id,
    }).eq('key', key);
  }
}