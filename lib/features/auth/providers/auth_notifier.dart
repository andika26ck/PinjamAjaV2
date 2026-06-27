import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../data/models/user_profile.dart';
import 'auth_provider.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
    }
  }

  /// Mengembalikan true jika session langsung aktif (auto-login).
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final hasSession =
          await ref.read(authRepositoryProvider).signUpWithEmail(
                fullName: fullName,
                email: email,
                phone: phone,
                password: password,
              );
      state = const AsyncData(null);
      return hasSession;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
    }
  }

  /// Update role lalu refresh profil; return true bila sukses.
  Future<bool> updateRole(UserRole role) async {
    state = const AsyncLoading();
    try {
      final session = ref.read(authRepositoryProvider).currentSession;
      if (session == null) {
        throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
      }
      await ref
          .read(authRepositoryProvider)
          .updateRole(userId: session.user.id, role: role);
      await ref.read(appAuthProvider.notifier).refreshProfile();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }
}