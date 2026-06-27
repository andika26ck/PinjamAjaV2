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
    // Jika session langsung aktif, pastikan baris profil tersimpan
    // (melengkapi trigger handle_new_user untuk name & phone).
    if (user != null && res.session != null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'name': fullName,
        'phone': phone,
      });
    }

    return res.session != null;
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
  Future<void> sendPasswordReset(String email) => _auth.resetPasswordForEmail(
        email,
        redirectTo: AppConstants.oauthRedirectUrl,
      );

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