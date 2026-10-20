import 'dart:typed_data';

/// Satu bukti (foto) yang akan diunggah untuk sengketa.
class EvidenceUpload {
  final Uint8List bytes;
  final String fileExtension; // 'jpg' | 'png'
  const EvidenceUpload({required this.bytes, this.fileExtension = 'jpg'});
}

/// Kontrak repository untuk pengajuan sengketa sisi user.
abstract class DisputeRepository {
  /// Unggah satu bukti ke bucket privat `dispute-evidence`, kembalikan signed
  /// URL berumur panjang agar admin bisa menampilkannya.
  Future<String> uploadEvidence({
    required String userId,
    required String bookingId,
    required EvidenceUpload file,
    required int index,
  });

  /// Buat baris sengketa di tabel `disputes` (status -> open).
  Future<void> submitDispute({
    required String bookingId,
    required String openedBy,
    String? againstId,
    required String reason,
    String? description,
    required List<String> evidenceUrls,
  });

  /// Cek apakah booking sudah punya sengketa yang masih aktif (open/reviewing).
  Future<bool> hasActiveDispute(String bookingId);
}