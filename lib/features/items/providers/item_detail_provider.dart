import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/item.dart';
import '../../../data/models/review.dart';
import '../../../data/models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/item_repository.dart';
import '../data/supabase_item_repository.dart';

part 'item_detail_provider.g.dart';

@Riverpod(keepAlive: true)
ItemRepository itemRepository(ItemRepositoryRef ref) =>
    SupabaseItemRepository(ref.watch(supabaseClientProvider));

/// Gabungan data untuk layar detail barang.
class ItemDetailBundle {
  final Item item;
  final UserProfile? owner;
  final List<Review> reviews;
  final List<Item> similar;

  const ItemDetailBundle({
    required this.item,
    this.owner,
    this.reviews = const [],
    this.similar = const [],
  });
}

@riverpod
Future<ItemDetailBundle> itemDetail(ItemDetailRef ref, String itemId) async {
  final repo = ref.watch(itemRepositoryProvider);
  final item = await repo.fetchItemById(itemId);

  // Ambil owner, ulasan, & barang serupa secara paralel.
  final results = await Future.wait([
    repo.fetchOwner(item.ownerId),
    repo.fetchReviews(itemId),
    repo.fetchSimilarItems(
      categoryId: item.categoryId,
      excludeItemId: item.id,
    ),
  ]);

  return ItemDetailBundle(
    item: item,
    owner: results[0] as UserProfile?,
    reviews: results[1] as List<Review>,
    similar: results[2] as List<Item>,
  );
}