import '../../../data/models/category.dart';
import '../../../data/models/item.dart';
import 'search_filters.dart';

/// Pengurutan untuk daftar item di Home.
enum HomeSort {
  terbaru,
  terdekat,
  termurah;

  String get label => switch (this) {
        HomeSort.terbaru => 'Terbaru',
        HomeSort.terdekat => 'Terdekat',
        HomeSort.termurah => 'Termurah',
      };
}

abstract class HomeRepository {
  Future<List<Category>> fetchCategories();

  Future<List<Item>> fetchItems({
    String? categoryId,
    HomeSort sort,
    int limit,
  });

  Future<List<Item>> fetchPopularItems({int limit});

  Future<List<Item>> searchItems({
    required String query,
    required SearchFilters filters,
    int limit,
  });
}