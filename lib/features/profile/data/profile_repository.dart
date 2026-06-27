import 'dart:typed_data';

import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';
import '../../review/data/review_repository.dart' show ReviewWithAuthor;

/// Ringkasan statistik untuk header profil.
class ProfileStats {
  final int completedRentals; // Booking selesai (sebagai penyewa)
  final int itemsListed; // Barang yang disewakan (sebagai pemilik)
  final int reviewsReceived; // Ulasan diterima (di barang miliknya)

  const ProfileStats({
    this.completedRentals = 0,
    this.itemsListed = 0,
    this.reviewsReceived = 0,
  });
}

/// Data gabungan untuk layar profil publik.
class PublicProfileData {
  final UserProfile profile;
  final List<Item> activeItems;
  final List<ReviewWithAuthor> reviews;

  const PublicProfileData({
    required this.profile,
    required this.activeItems,
    required this.reviews,
  });
}

/// Kontrak repository untuk fitur profil.
abstract class ProfileRepository {
  Future<UserProfile> fetchProfile(String userId);

  Future<UserProfile> updateProfile({
    required String userId,
    required String name,
    required String phone,
    UserRole? role,
  });

  /// Unggah foto profil ke Storage, simpan ke `avatar_url`, kembalikan URL publik.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String fileExtension,
  });

  /// Statistik untuk header profil sendiri.
  Future<ProfileStats> fetchStats(String userId);

  /// Barang aktif (status available) milik user — untuk profil publik.
  Future<List<Item>> fetchActiveItems(String userId);

  /// Ulasan yang diterima user (di semua barang miliknya).
  Future<List<ReviewWithAuthor>> fetchReceivedReviews(String userId);
}