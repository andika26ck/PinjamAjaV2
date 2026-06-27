import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/category.dart';
import '../../../data/models/item.dart';
import 'home_repository.dart';
import 'search_filters.dart';

class SupabaseHomeRepository implements HomeRepository {
  SupabaseHomeRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Category>> fetchCategories() async {
    final rows = await _client.from('categories').select().order('name');
    return (rows as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Item>> fetchItems({
    String? categoryId,
    HomeSort sort = HomeSort.terbaru,
    int limit = 20,
  }) async {
    var query =
        _client.from('items').select().eq('status', AppConstants.itemStatusAvailable);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final rows = switch (sort) {
      HomeSort.termurah =>
        await query.order('price_per_day', ascending: true).limit(limit),
      // TODO: "terdekat" butuh koordinat user + PostGIS; sementara pakai terbaru.
      HomeSort.terdekat =>
        await query.order('created_at', ascending: false).limit(limit),
      HomeSort.terbaru =>
        await query.order('created_at', ascending: false).limit(limit),
    };

    return (rows as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Item>> fetchPopularItems({int limit = 10}) async {
    final rows = await _client
        .from('items')
        .select()
        .eq('status', AppConstants.itemStatusAvailable)
        .order('total_reviews', ascending: false)
        .order('rating', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Item>> searchItems({
    required String query,
    required SearchFilters filters,
    int limit = 50,
  }) async {
    var q =
        _client.from('items').select().eq('status', AppConstants.itemStatusAvailable);

    final text = query.trim();
    if (text.isNotEmpty) {
      // Bersihkan karakter yang bisa merusak sintaks filter .or().
      final safe = text.replaceAll(',', ' ').replaceAll('%', '');
      q = q.or('title.ilike.%$safe%,description.ilike.%$safe%');
    }
    if (filters.categoryIds.isNotEmpty) {
      q = q.inFilter('category_id', filters.categoryIds);
    }
    if (filters.conditions.isNotEmpty) {
      q = q.inFilter('condition', filters.conditions);
    }
    q = q.gte('price_per_day', filters.minPrice).lte('price_per_day', filters.maxPrice);

    final rows = await q.order('created_at', ascending: false).limit(limit);
    return (rows as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}