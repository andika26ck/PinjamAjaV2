import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/manual_payment_model.dart';
import '../data/models/payment_account_model.dart';
import '../data/repositories/manual_payment_repository.dart';
import '../data/repositories/supabase_manual_payment_repository.dart';

final manualPaymentRepositoryProvider =
    Provider<ManualPaymentRepository>((ref) =>
        SupabaseManualPaymentRepository(ref.watch(supabaseClientProvider)));

final paymentAccountsProvider =
    FutureProvider<List<PaymentAccountModel>>((ref) =>
        ref.watch(manualPaymentRepositoryProvider).fetchActiveAccounts());

final manualPaymentByBookingProvider =
    StreamProvider.family<ManualPaymentModel?, String>((ref, bookingId) =>
        ref.watch(manualPaymentRepositoryProvider).watchPayment(bookingId));

/// Antrian verifikasi admin (status: pending/paid/failed atau null=semua).
final manualQueueProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, status) =>
        ref.watch(manualPaymentRepositoryProvider).fetchManualQueue(status: status));