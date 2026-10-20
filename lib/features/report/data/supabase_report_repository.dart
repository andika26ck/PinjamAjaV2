import 'package:supabase_flutter/supabase_flutter.dart';

import 'report_repository.dart';

class SupabaseReportRepository implements ReportRepository {
  final SupabaseClient _client;
  SupabaseReportRepository(this._client);

  @override
  Future<void> submitReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    final desc = description?.trim();
    await _client.from('reports').insert({
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'description': (desc == null || desc.isEmpty) ? null : desc,
      // status default 'open' di DB; admin yang mengubahnya nanti.
    });
  }
}