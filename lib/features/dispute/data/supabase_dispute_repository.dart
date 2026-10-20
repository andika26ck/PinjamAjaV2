import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import 'dispute_repository.dart';

class SupabaseDisputeRepository implements DisputeRepository {
  final SupabaseClient _client;
  SupabaseDisputeRepository(this._client);

  // Signed URL berumur 1 tahun (bucket privat).
  static const int _signedUrlTtl = 60 * 60 * 24 * 365;

  @override
  Future<String> uploadEvidence({
    required String userId,
    required String bookingId,
    required EvidenceUpload file,
    required int index,
  }) async {
    final bucket = _client.storage.from(AppConstants.disputeEvidenceBucket);
    final ts = DateTime.now().millisecondsSinceEpoch;
    // Folder pertama = uid agar cocok dengan storage policy.
    final path = '$userId/$bookingId/ev_${ts}_$index.${file.fileExtension}';
    await bucket.uploadBinary(
      path,
      file.bytes,
      fileOptions: FileOptions(
        contentType:
            file.fileExtension == 'png' ? 'image/png' : 'image/jpeg',
        upsert: true,
      ),
    );
    // Bucket privat -> kembalikan signed URL (bukan getPublicUrl).
    return bucket.createSignedUrl(path, _signedUrlTtl);
  }

  @override
  Future<void> submitDispute({
    required String bookingId,
    required String openedBy,
    String? againstId,
    required String reason,
    String? description,
    required List<String> evidenceUrls,
  }) async {
    final desc = description?.trim();
    await _client.from('disputes').insert({
      'booking_id': bookingId,
      'opened_by': openedBy,
      'against_id': againstId,
      'reason': reason,
      'description': (desc == null || desc.isEmpty) ? null : desc,
      'evidence_urls': evidenceUrls,
      // 'status' sengaja tidak dikirim -> DB pakai default 'open'.
    });
  }

  @override
  Future<bool> hasActiveDispute(String bookingId) async {
    final rows = await _client
        .from('disputes')
        .select('id')
        .eq('booking_id', bookingId)
        .inFilter('status', ['open', 'reviewing']);
    return (rows as List).isNotEmpty;
  }
}