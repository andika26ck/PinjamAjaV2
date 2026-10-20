import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/report_repository.dart';
import '../data/supabase_report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => SupabaseReportRepository(ref.watch(supabaseClientProvider)),
);

final reportControllerProvider =
    AsyncNotifierProvider<ReportController, void>(ReportController.new);

/// Controller aksi pelaporan. State `AsyncValue<void>` untuk loading & error.
class ReportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  String _uid() {
    final id = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
    }
    return id;
  }

  Future<bool> submit({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(reportRepositoryProvider).submitReport(
            reporterId: _uid(),
            targetType: targetType,
            targetId: targetId,
            reason: reason,
            description: description,
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }
}