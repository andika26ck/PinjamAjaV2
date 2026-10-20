import 'dart:typed_data';

/// Satu dokumen KYC yang akan diunggah (KTP atau selfie).
class KycUpload {
  final Uint8List bytes;
  final String fileExtension; // 'jpg' | 'png'
  const KycUpload({required this.bytes, this.fileExtension = 'jpg'});
}

/// Kontrak repository untuk pengajuan KYC sisi user.
abstract class KycRepository {
  /// Unggah satu dokumen ke bucket privat `kyc-docs`, kembalikan signed URL
  /// berumur panjang agar admin bisa menampilkannya.
  Future<String> uploadDocument({
    required String userId,
    required String slot, // 'ktp' | 'selfie'
    required KycUpload file,
  });

  /// Simpan pengajuan KYC ke profil (status -> pending).
  Future<void> submitKyc({
    required String userId,
    required String fullName,
    required String idNumber,
    required String idPhotoUrl,
    required String selfieUrl,
  });
}