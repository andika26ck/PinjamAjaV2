import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';

part 'admin_gate_provider.g.dart';

/// True bila user yang sedang login adalah admin.
@riverpod
bool isAdmin(IsAdminRef ref) =>
    ref.watch(appAuthProvider).profile?.isAdmin ?? false;

/// True bila akun user sedang dibekukan (suspended).
@riverpod
bool isSuspended(IsSuspendedRef ref) =>
    ref.watch(appAuthProvider).profile?.isSuspended ?? false;