import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/item.dart';
import 'wishlist_repository.dart';

class SupabaseWishlistRepository implements WishlistRepository {
  final SupabaseClient _client;
  SupabaseWishlistRepository(this._client);

  @override
  Future<Set<String>> fetchWishlistItemIds(String userId) async {
    final rows = await _client
        .from('wishlists')
        .select('item_id')
        .eq('user_id', userId);
    return (rows as List)
        .map((e) => e['item_id'] as String)
        .toSet();
  }

  @override
  Future<List<Item>> fetchWishlistItems(String userId) async {
    // Join ke items; ambil baris item yang masih ada.
    final rows = await _client
        .from('wishlists')
        .select('created_at, item:items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final items = <Item>[];
    for (final row in (rows as List)) {
      final m = row as Map<String, dynamic>;
      final itemJson = m['item'] as Map<String, dynamic>?;
      if (itemJson != null) {
        items.add(Item.fromJson(itemJson));
      }
    }
    return items;
  }

  @override
  Future<void> add(String userId, String itemId) async {
    // Upsert agar tidak error bila sudah ada (unique user_id,item_id).
    await _client.from('wishlists').upsert(
      {'user_id': userId, 'item_id': itemId},
      onConflict: 'user_id,item_id',
      ignoreDuplicates: true,
    );
  }

  @override
  Future<void> remove(String userId, String itemId) async {
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('item_id', itemId);
  }
}