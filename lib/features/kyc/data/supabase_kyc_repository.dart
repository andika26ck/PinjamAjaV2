import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import 'kyc_repository.dart';

class SupabaseKycRepository implements KycRepository {
  final SupabaseClient _client;
  SupabaseKycRepository(this._client);

  // Signed URL berumur 1 tahun (bucket privat).
  static const int _signedUrlTtl = 60 * 60 * 24 * 365;

  @override
  Future<String> uploadDocument({
    required String userId,
    required String slot,
    required KycUpload file,
  }) async {
    final bucket = _client.storage.from(AppConstants.kycDocsBucket);
    final ts = DateTime.now().millisecondsSinceEpoch;
    // Folder pertama = uid agar cocok dengan storage policy.
    final path = '$userId/${slot}_$ts.${file.fileExtension}';
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
  Future<void> submitKyc({
    required String userId,
    required String fullName,
    required String idNumber,
    required String idPhotoUrl,
    required String selfieUrl,
  }) async {
    await _client.from('profiles').update({
      'kyc_full_name': fullName.trim(),
      'kyc_id_number': idNumber.trim(),
      'kyc_id_photo_url': idPhotoUrl,
      'kyc_selfie_url': selfieUrl,
      'kyc_status': 'pending',
      'kyc_submitted_at': DateTime.now().toUtc().toIso8601String(),
      // Reset alasan penolakan saat mengajukan ulang.
      'kyc_reject_reason': null,
    }).eq('id', userId);
  }
}