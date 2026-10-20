import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/payout_account.dart';
import '../data/models/payout_model.dart';
import '../data/repositories/manual_payout_repository.dart';
import '../data/repositories/supabase_manual_payout_repository.dart';

final manualPayoutRepositoryProvider = Provider<ManualPayoutRepository>((ref) =>
    SupabaseManualPayoutRepository(ref.watch(supabaseClientProvider)));

final myPayoutAccountProvider = FutureProvider<PayoutAccount>((ref) =>
    ref.watch(manualPayoutRepositoryProvider).getMyPayoutAccount());

final payoutQueueProvider =
    FutureProvider.family<List<ManualPayoutModel>, String?>((ref, status) =>
        ref.watch(manualPayoutRepositoryProvider).fetchPayoutQueue(status: status));