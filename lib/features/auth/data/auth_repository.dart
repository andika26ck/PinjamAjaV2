import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_profile.dart';

/// Kontrak repository autentikasi (abstract).
abstract class AuthRepository {
  Session? get currentSession;
  User? get currentUser;

  Stream<AuthState> authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Mengembalikan true jika session langsung aktif
  /// (email confirmation dimatikan di Supabase).
  Future<bool> signUpWithEmail({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<bool> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  Future<UserProfile?> fetchProfile(String userId);

  Future<UserProfile> updateRole({
    required String userId,
    required UserRole role,
  });
}