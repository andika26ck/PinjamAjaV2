import 'dart:typed_data';

import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/review.dart';
import '../../../data/models/user_profile.dart';

/// Satu gambar yang akan diunggah ke Storage.
class ItemImageUpload {
  final Uint8List bytes;
  final String fileExtension; // 'jpg' | 'png'
  const ItemImageUpload({required this.bytes, this.fileExtension = 'jpg'});
}

/// Kontrak repository untuk fitur barang (detail, listing, owner).
abstract class ItemRepository {
  Future<Item> fetchItemById(String id);
  Future<UserProfile?> fetchOwner(String ownerId);
  Future<List<Review>> fetchReviews(String itemId, {int limit = 20});
  Future<List<Item>> fetchSimilarItems({
    required String categoryId,
    required String excludeItemId,
    int limit = 10,
  });

  Future<List<Item>> fetchOwnerItems(String ownerId);
  Future<List<Booking>> fetchOwnerBookings(String ownerId);
  Future<List<Booking>> fetchItemBookings(String itemId);

  Future<List<String>> uploadImages({
    required String ownerId,
    required List<ItemImageUpload> images,
  });
  Future<Item> createItem(Map<String, dynamic> payload);
  Future<Item> updateItem({
    required String id,
    required Map<String, dynamic> payload,
  });
  Future<void> deleteItem(String id);
}