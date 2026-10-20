import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_profile.dart';
import 'auth_repository.dart';

/// Implementasi [AuthRepository] menggunakan Supabase.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  SupabaseAuthRepository(this._client);

  GoTrueClient get _auth => _client.auth;

  @override
  Session? get currentSession => _auth.currentSession;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> signUpWithEmail({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': fullName, 'phone': phone},
    );

    final user = res.user;
    final hasSession = res.session != null;

    // Jika session langsung aktif (konfirmasi email dimatikan),
    // simpan profil lalu LANGSUNG sign out supaya user tidak auto-login.
    if (user != null && hasSession) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'name': fullName,
        'phone': phone,
      });
      await _auth.signOut();
    }

    // true  = perlu verifikasi email (belum ada session)
    // false = pendaftaran selesai, user bisa langsung login
    return !hasSession;
  }

  @override
  Future<bool> signInWithGoogle() {
    return _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConstants.oauthRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: AppConstants.oauthRedirectUrl,
      );
    } on StateError catch (e) {
      // Workaround bug gotrue: kadang melempar "Bad state: Future already
      // completed" SETELAH email reset benar-benar terkirim (completer PKCE/
      // redirect ter-complete dua kali). Abaikan khusus error ini agar tidak
      // muncul error palsu ke user.
      if (!e.toString().toLowerCase().contains('future already completed')) {
        rethrow;
      }
    }
  }

  @override
  bool get isEmailVerified => _auth.currentUser?.emailConfirmedAt != null;

  @override
  Future<void> verifyCurrentPassword(String password) async {
    final email = _auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw AuthException('Email akun tidak ditemukan.');
    }
    // Jika kredensial salah, signInWithPassword melempar AuthException.
    await _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> resendEmailVerification(String email) async {
    await _auth.resend(type: OtpType.signup, email: email);
  }

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    final data =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return data == null ? null : UserProfile.fromJson(data);
  }

  @override
  Future<UserProfile> updateRole({
    required String userId,
    required UserRole role,
  }) async {
    final data = await _client
        .from('profiles')
        .update({'role': role.value})
        .eq('id', userId)
        .select()
        .single();
    return UserProfile.fromJson(data);
  }
}