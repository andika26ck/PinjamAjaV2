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

  /// Apakah email user yang sedang login sudah terverifikasi.
  bool get isEmailVerified;

  /// Verifikasi kata sandi lama (konfirmasi sebelum ganti sandi).
  Future<void> verifyCurrentPassword(String password);

  /// Ganti kata sandi user yang sedang login.
  Future<void> updatePassword(String newPassword);

  /// Kirim ulang email verifikasi pendaftaran ke [email].
  Future<void> resendEmailVerification(String email);

  Future<UserProfile?> fetchProfile(String userId);

  Future<UserProfile> updateRole({
    required String userId,
    required UserRole role,
  });
}