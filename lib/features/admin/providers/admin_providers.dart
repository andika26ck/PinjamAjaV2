import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/admin_stats.dart';
import '../../../data/models/dispute.dart';
import '../../../data/models/item.dart';
import '../../../data/models/payout.dart';
import '../../../data/models/report.dart';
import '../../../data/models/user_profile.dart';
import 'admin_repository_provider.dart';

part 'admin_providers.g.dart';

/// Statistik ringkas untuk dashboard.
@riverpod
Future<AdminDashboardStats> adminDashboardStats(
        AdminDashboardStatsRef ref) =>
    ref.watch(adminRepositoryProvider).fetchDashboardStats();

/// Daftar user (opsional: cari + hanya yang disuspend).
@riverpod
Future<List<UserProfile>> adminUsers(AdminUsersRef ref,
        {String? query, bool? suspendedOnly}) =>
    ref
        .watch(adminRepositoryProvider)
        .fetchUsers(query: query, suspendedOnly: suspendedOnly);

/// Antrian KYC menunggu review.
@riverpod
Future<List<UserProfile>> adminKycQueue(AdminKycQueueRef ref) =>
    ref.watch(adminRepositoryProvider).fetchKycQueue();

/// Item untuk moderasi (opsional filter: ok | flagged | removed).
@riverpod
Future<List<Item>> adminModerationItems(AdminModerationItemsRef ref,
        {String? moderationStatus}) =>
    ref
        .watch(adminRepositoryProvider)
        .fetchItemsForModeration(moderationStatus: moderationStatus);

/// Laporan (opsional filter status).
@riverpod
Future<List<Report>> adminReports(AdminReportsRef ref, {String? status}) =>
    ref.watch(adminRepositoryProvider).fetchReports(status: status);

/// Sengketa (opsional filter status).
@riverpod
Future<List<Dispute>> adminDisputes(AdminDisputesRef ref, {String? status}) =>
    ref.watch(adminRepositoryProvider).fetchDisputes(status: status);

/// Payout / escrow (opsional filter status).
@riverpod
Future<List<Payout>> adminPayouts(AdminPayoutsRef ref, {String? status}) =>
    ref.watch(adminRepositoryProvider).fetchPayouts(status: status);

/// Konfigurasi platform (key -> value).
@riverpod
Future<Map<String, dynamic>> adminConfig(AdminConfigRef ref) =>
    ref.watch(adminRepositoryProvider).fetchConfig();