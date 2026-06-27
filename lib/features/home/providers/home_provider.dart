import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/category.dart';
import '../../../data/models/item.dart';
import '../../auth/providers/auth_provider.dart'; // supabaseClientProvider
import '../data/home_repository.dart';
import '../data/supabase_home_repository.dart';

part 'home_provider.g.dart';

@Riverpod(keepAlive: true)
HomeRepository homeRepository(HomeRepositoryRef ref) =>
    SupabaseHomeRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Category>> categories(CategoriesRef ref) =>
    ref.watch(homeRepositoryProvider).fetchCategories();

/// State filter untuk section "Terdekat dari Kamu".
class HomeFilter {
  final String? categoryId;
  final HomeSort sort;

  const HomeFilter({this.categoryId, this.sort = HomeSort.terbaru});

  HomeFilter copyWith({
    String? categoryId,
    bool resetCategory = false,
    HomeSort? sort,
  }) =>
      HomeFilter(
        categoryId: resetCategory ? null : (categoryId ?? this.categoryId),
        sort: sort ?? this.sort,
      );
}

@riverpod
class HomeFilterController extends _$HomeFilterController {
  @override
  HomeFilter build() => const HomeFilter();

  void selectCategory(String? id) => state = id == null
      ? state.copyWith(resetCategory: true)
      : state.copyWith(categoryId: id);

  void setSort(HomeSort sort) => state = state.copyWith(sort: sort);
}

@riverpod
Future<List<Item>> nearbyItems(NearbyItemsRef ref) {
  final filter = ref.watch(homeFilterControllerProvider);
  return ref.watch(homeRepositoryProvider).fetchItems(
        categoryId: filter.categoryId,
        sort: filter.sort,
      );
}

@riverpod
Future<List<Item>> popularItems(PopularItemsRef ref) =>
    ref.watch(homeRepositoryProvider).fetchPopularItems();