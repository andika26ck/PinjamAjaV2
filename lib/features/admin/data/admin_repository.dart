import '../../../data/models/admin_stats.dart';
import '../../../data/models/dispute.dart';
import '../../../data/models/item.dart';
import '../../../data/models/payout.dart';
import '../../../data/models/report.dart';
import '../../../data/models/user_profile.dart';

/// Kontrak repository modul admin. Semua aksi tulis memanggil RPC server
/// yang dijaga `is_admin()`, jadi aman walau dipanggil dari klien.
abstract class AdminRepository {
  Future<AdminDashboardStats> fetchDashboardStats();

  // --- Users & KYC ---
  Future<List<UserProfile>> fetchUsers({String? query, bool? suspendedOnly});
  Future<List<UserProfile>> fetchKycQueue();
  Future<UserProfile> setSuspended({
    required String userId,
    required bool suspended,
    String? reason,
  });
  Future<UserProfile> reviewKyc({
    required String userId,
    required bool approve,
    String? rejectReason,
  });

  // --- Moderasi item ---
  Future<List<Item>> fetchItemsForModeration({String? moderationStatus});
  Future<Item> moderateItem({
    required String itemId,
    required String status, // ok | flagged | removed
    String? note,
  });

  // --- Laporan ---
  Future<List<Report>> fetchReports({String? status});
  Future<Report> updateReportStatus({
    required String reportId,
    required String status, // open | reviewing | resolved | dismissed
    String? adminNote,
  });

  // --- Sengketa ---
  Future<List<Dispute>> fetchDisputes({String? status});
  Future<Dispute> resolveDispute({
    required String disputeId,
    required String resolution,
    String? note,
    num? refundAmount,
  });

  // --- Payout / escrow ---
  Future<List<Payout>> fetchPayouts({String? status});
  Future<Payout> releasePayout(String payoutId);

  // --- Konfigurasi platform ---
  Future<Map<String, dynamic>> fetchConfig();
  Future<void> updateConfig({required String key, required Object? value});
}