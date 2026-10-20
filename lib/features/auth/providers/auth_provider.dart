import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_profile.dart';
import '../data/auth_repository.dart';
import '../data/supabase_auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) =>
    Supabase.instance.client;

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) =>
    SupabaseAuthRepository(ref.watch(supabaseClientProvider));

enum AuthStatus { loading, unauthenticated, authenticated }

class AppAuthState {
  final AuthStatus status;
  final UserProfile? profile;

  const AppAuthState({required this.status, this.profile});

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasRole => profile?.role != null;

  static const loading = AppAuthState(status: AuthStatus.loading);
  static const unauthenticated =
      AppAuthState(status: AuthStatus.unauthenticated);
}

@Riverpod(keepAlive: true)
class AppAuth extends _$AppAuth {
  StreamSubscription<AuthState>? _sub;

  @override
  AppAuthState build() {
    final repo = ref.watch(authRepositoryProvider);
    _sub = repo.authStateChanges().listen(_onAuthChange);
    ref.onDispose(() => _sub?.cancel());
    _bootstrap(repo);
    return AppAuthState.loading;
  }

  Future<void> _bootstrap(AuthRepository repo) async {
    final session = repo.currentSession;
    if (session == null) {
      state = AppAuthState.unauthenticated;
    } else {
      await _loadProfile(session.user.id);
    }
  }

  Future<void> _onAuthChange(AuthState data) async {
    final session = data.session;
    if (session == null) {
      state = AppAuthState.unauthenticated;
    } else if (state.status != AuthStatus.authenticated ||
        state.profile == null) {
      await _loadProfile(session.user.id);
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final profile =
          await ref.read(authRepositoryProvider).fetchProfile(userId);
      state = AppAuthState(status: AuthStatus.authenticated, profile: profile);
    } catch (_) {
      // Tetap authenticated walau profil gagal dimuat; role dianggap belum ada.
      state =
          const AppAuthState(status: AuthStatus.authenticated, profile: null);
    }
  }

  /// Muat ulang profil (mis. setelah update role).
  Future<void> refreshProfile() async {
    final session = ref.read(authRepositoryProvider).currentSession;
    if (session != null) await _loadProfile(session.user.id);
  }
}