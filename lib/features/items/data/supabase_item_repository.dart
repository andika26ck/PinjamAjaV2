import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/review.dart';
import '../../../data/models/user_profile.dart';
import 'item_repository.dart';

class SupabaseItemRepository implements ItemRepository {
  final SupabaseClient _client;
  SupabaseItemRepository(this._client);

  List<Map<String, dynamic>> _rows(dynamic data) =>
      (data as List).cast<Map<String, dynamic>>();

  @override
  Future<Item> fetchItemById(String id) async {
    final data = await _client.from('items').select().eq('id', id).single();
    return Item.fromJson(data);
  }

  @override
  Future<UserProfile?> fetchOwner(String ownerId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', ownerId)
        .maybeSingle();
    return data == null ? null : UserProfile.fromJson(data);
  }

  @override
  Future<List<Review>> fetchReviews(String itemId, {int limit = 20}) async {
    final rows = _rows(await _client
        .from('reviews')
        .select()
        .eq('item_id', itemId)
        .order('created_at', ascending: false)
        .limit(limit));
    final reviews = rows.map(Review.fromJson).toList();
    if (reviews.isEmpty) return reviews;

    // Ambil profil reviewer dalam satu query (hindari N+1).
    final reviewerIds = reviews.map((r) => r.reviewerId).toSet().toList();
    final profileRows = _rows(await _client
        .from('profiles')
        .select('id, name, avatar_url')
        .inFilter('id', reviewerIds));
    final byId = {
      for (final p in profileRows) p['id'] as String: p,
    };
    return reviews.map((r) {
      final p = byId[r.reviewerId];
      return r.withReviewer(
        name: p?['name'] as String?,
        avatarUrl: p?['avatar_url'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<Item>> fetchSimilarItems({
    required String categoryId,
    required String excludeItemId,
    int limit = 10,
  }) async {
    if (categoryId.isEmpty) return [];
    final rows = _rows(await _client
        .from('items')
        .select()
        .eq('category_id', categoryId)
        .eq('status', AppConstants.itemStatusAvailable)
        .neq('id', excludeItemId)
        .order('rating', ascending: false)
        .limit(limit));
    return rows.map(Item.fromJson).toList();
  }

  @override
  Future<List<Item>> fetchOwnerItems(String ownerId) async {
    final rows = _rows(await _client
        .from('items')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false));
    return rows.map(Item.fromJson).toList();
  }

  @override
  Future<List<Booking>> fetchOwnerBookings(String ownerId) async {
    final rows = _rows(await _client
        .from('bookings')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false));
    return rows.map(Booking.fromJson).toList();
  }

  @override
  Future<List<Booking>> fetchItemBookings(String itemId) async {
    final rows = _rows(await _client
        .from('bookings')
        .select()
        .eq('item_id', itemId)
        .order('created_at', ascending: false));
    return rows.map(Booking.fromJson).toList();
  }

  @override
  Future<List<String>> uploadImages({
    required String ownerId,
    required List<ItemImageUpload> images,
  }) async {
    final bucket = _client.storage.from(AppConstants.itemImagesBucket);
    final urls = <String>[];
    final ts = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < images.length; i++) {
      final img = images[i];
      // Path diawali ownerId agar cocok dengan storage policy (folder = uid).
      final path = '$ownerId/${ts}_$i.${img.fileExtension}';
      await bucket.uploadBinary(
        path,
        img.bytes,
        fileOptions: FileOptions(
          contentType: img.fileExtension == 'png' ? 'image/png' : 'image/jpeg',
          upsert: true,
        ),
      );
      urls.add(bucket.getPublicUrl(path));
    }
    return urls;
  }

  @override
  Future<Item> createItem(Map<String, dynamic> payload) async {
    final data =
        await _client.from('items').insert(payload).select().single();
    return Item.fromJson(data);
  }

  @override
  Future<Item> updateItem({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _client
        .from('items')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return Item.fromJson(data);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _client.from('items').delete().eq('id', id);
  }
}