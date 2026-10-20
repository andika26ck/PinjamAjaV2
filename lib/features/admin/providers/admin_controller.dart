import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import 'admin_providers.dart';
import 'admin_repository_provider.dart';

part 'admin_controller.g.dart';

/// Aksi tulis admin. State `AsyncValue<void>` untuk loading & error.
/// Tiap aksi meng-`invalidate` provider terkait agar data segar.
@riverpod
class AdminController extends _$AdminController {
  @override
  FutureOr<void> build() {}

  Future<bool> setSuspended({
    required String userId,
    required bool suspended,
    String? reason,
  }) =>
      _run(() async {
        await ref.read(adminRepositoryProvider).setSuspended(
              userId: userId,
              suspended: suspended,
              reason: reason,
            );
        ref.invalidate(adminUsersProvider);
      });

  Future<bool> reviewKyc({
    required String userId,
    required bool approve,
    String? rejectReason,
  }) =>
      _run(() async {
        await ref.read(adminRepositoryProvider).reviewKyc(
              userId: userId,
              approve: approve,
              rejectReason: rejectReason,
            );
        ref.invalidate(adminKycQueueProvider);
        ref.invalidate(adminUsersProvider);
      });

  Future<bool> moderateItem({
    required String itemId,
    required String status,
    String? note,
  }) =>
      _run(() async {
        await ref.read(adminRepositoryProvider).moderateItem(
              itemId: itemId,
              status: status,
              note: note,
            );
        ref.invalidate(adminModerationItemsProvider);
      });

  Future<bool> updateReport({
    required String reportId,
    required String status,
    String? adminNote,
  }) =>
      _run(() async {
        await ref.read(adminRepositoryProvider).updateReportStatus(
              reportId: reportId,
              status: status,
              adminNote: adminNote,
            );
        ref.invalidate(adminReportsProvider);
      });

  Future<bool> resolveDispute({
    required String disputeId,
    required String resolution,
    String? note,
    num? refundAmount,
  }) =>
      _run(() async {
        await ref.read(adminRepositoryProvider).resolveDispute(
              disputeId: disputeId,
              resolution: resolution,
              note: note,
              refundAmount: refundAmount,
            );
        ref.invalidate(adminDisputesProvider);
        ref.invalidate(adminPayoutsProvider);
        ref.invalidate(adminDashboardStatsProvider);
      });

  Future<bool> releasePayout(String payoutId) => _run(() async {
        await ref.read(adminRepositoryProvider).releasePayout(payoutId);
        ref.invalidate(adminPayoutsProvider);
        ref.invalidate(adminDashboardStatsProvider);
      });

  Future<bool> updateConfig({required String key, required Object? value}) =>
      _run(() async {
        await ref
            .read(adminRepositoryProvider)
            .updateConfig(key: key, value: value);
        ref.invalidate(adminConfigProvider);
      });

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }
}