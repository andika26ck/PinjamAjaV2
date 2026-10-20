/// Kontrak repository untuk pelaporan dari user.
abstract class ReportRepository {
  /// Kirim laporan. `targetType`: 'item' | 'user' | 'review' | 'chat'.
  Future<void> submitReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  });
}