import '../../../data/models/item.dart';

abstract class WishlistRepository {
  /// Set id item yang sudah di-wishlist user (untuk cek cepat di kartu).
  Future<Set<String>> fetchWishlistItemIds(String userId);

  /// Daftar item lengkap yang di-wishlist (untuk layar Wishlist).
  Future<List<Item>> fetchWishlistItems(String userId);

  Future<void> add(String userId, String itemId);

  Future<void> remove(String userId, String itemId);
}