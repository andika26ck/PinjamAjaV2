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
  final List<Item> items; // semua barang publik (semua status kecuali 'inactive')
  final List<ReviewWithAuthor> reviews;
  final int transactionsCount; // transaksi selesai (sebagai pemilik/penyewa)

  const PublicProfileData({
    required this.profile,
    required this.items,
    required this.reviews,
    this.transactionsCount = 0,
  });

  /// Rata-rata rating dihitung dari ulasan yang diterima — lebih andal
  /// daripada kolom profiles.rating yang bisa basi bila trigger SQL belum jalan.
  double get computedRating => reviews.isEmpty
      ? profile.rating
      : reviews.map((r) => r.review.rating).reduce((a, b) => a + b) /
          reviews.length;

  int get reviewsCount => reviews.length;

  /// Barang yang masih bisa disewa (status available).
  List<Item> get availableItems =>
      items.where((i) => i.status == 'available').toList();

  /// Barang yang sedang disewa (status rented).
  List<Item> get rentedItems =>
      items.where((i) => i.status == 'rented').toList();
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

  /// Semua barang publik milik user (semua status KECUALI 'inactive')
  /// — untuk profil publik dengan tab Semua / Tersedia.
  Future<List<Item>> fetchPublicItems(String userId);

  /// Jumlah transaksi selesai milik user (sebagai pemilik maupun penyewa).
  Future<int> fetchCompletedTransactions(String userId);

  /// Ulasan yang diterima user (di semua barang miliknya).
  Future<List<ReviewWithAuthor>> fetchReceivedReviews(String userId);
}