import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/deposit_refund_model.dart';
import '../data/repositories/manual_refund_repository.dart';
import '../data/repositories/supabase_manual_refund_repository.dart';

final manualRefundRepositoryProvider = Provider<ManualRefundRepository>((ref) =>
    SupabaseManualRefundRepository(ref.watch(supabaseClientProvider)));

final refundQueueProvider =
    FutureProvider.family<List<DepositRefundModel>, String?>((ref, status) =>
        ref.watch(manualRefundRepositoryProvider).fetchRefundQueue(status: status));