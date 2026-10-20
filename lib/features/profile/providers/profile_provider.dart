import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/auth_provider.dart';
import '../../review/data/review_repository.dart' show ReviewWithAuthor;
import '../data/profile_repository.dart';
import '../data/supabase_profile_repository.dart';

part 'profile_provider.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) =>
    SupabaseProfileRepository(ref.watch(supabaseClientProvider));

/// Profil user yang sedang login — sumber kebenaran tunggal dari state auth (Fase 1).
@riverpod
UserProfile? myProfile(MyProfileRef ref) => ref.watch(appAuthProvider).profile;

/// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
@riverpod
Future<ProfileStats> profileStats(ProfileStatsRef ref, String userId) {
  return ref.watch(profileRepositoryProvider).fetchStats(userId);
}

/// Data profil publik (profil + barang aktif + ulasan diterima).
@riverpod
Future<PublicProfileData> publicProfile(
    PublicProfileRef ref, String userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  final profile = await repo.fetchProfile(userId);
  final items = await repo.fetchPublicItems(userId);
  final reviews = await repo.fetchReceivedReviews(userId);
  final transactionsCount = await repo.fetchCompletedTransactions(userId);
  return PublicProfileData(
    profile: profile,
    items: items,
    reviews: reviews,
    transactionsCount: transactionsCount,
  );
}

/// Controller aksi profil. State `AsyncValue<void>` untuk loading & error.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

  String _uid() {
    final id = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
    }
    return id;
  }

  /// Simpan perubahan profil, lalu refresh state auth global.
  Future<bool> updateProfile({
    required String name,
    required String phone,
    UserRole? role,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            userId: _uid(),
            name: name,
            phone: phone,
            role: role,
          );
      await ref.read(appAuthProvider.notifier).refreshProfile();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  /// Kompres dulu via flutter_image_compress, lalu unggah ke bucket `avatars`.
  Future<bool> uploadAvatar(Uint8List bytes, String fileExtension) async {
    state = const AsyncLoading();
    try {
      final isPng = fileExtension.toLowerCase() == 'png';
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: isPng ? CompressFormat.png : CompressFormat.jpeg,
      );
      await ref.read(profileRepositoryProvider).uploadAvatar(
            userId: _uid(),
            bytes: compressed,
            fileExtension: fileExtension,
          );
      await ref.read(appAuthProvider.notifier).refreshProfile();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  /// Beralih peran cepat (Penyewa ⇄ Pemilik) dari layar profil.
  Future<bool> switchRole(UserRole role) {
    final current = ref.read(myProfileProvider);
    return updateProfile(
      name: current?.name ?? '',
      phone: current?.phone ?? '',
      role: role,
    );
  }

  /// Kirim email reset kata sandi (menu Keamanan).
  Future<bool> sendPasswordReset() async {
    final email = ref.read(supabaseClientProvider).auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      state = AsyncError(
        const AppException('Email tidak ditemukan pada akun ini.'),
        StackTrace.current,
      );
      return false;
    }
    state = const AsyncLoading();
    try {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  /// Keluar dari akun (delegasi ke AuthController Fase 1).
  Future<void> signOut() =>
      ref.read(authControllerProvider.notifier).signOut();
}