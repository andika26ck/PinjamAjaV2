import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../data/models/item.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/supabase_wishlist_repository.dart';
import '../data/wishlist_repository.dart';

part 'wishlist_provider.g.dart';

@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(WishlistRepositoryRef ref) =>
    SupabaseWishlistRepository(ref.watch(supabaseClientProvider));

/// Set id item yang di-wishlist user aktif. Mendukung optimistic update.
@Riverpod(keepAlive: true)
class WishlistIds extends _$WishlistIds {
  @override
  Future<Set<String>> build() async {
    final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return <String>{};
    return ref.watch(wishlistRepositoryProvider).fetchWishlistItemIds(uid);
  }

  /// Toggle wishlist dengan optimistic update + rollback bila gagal.
  Future<void> toggle(String itemId) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) {
      throw const AppException('Silakan masuk dulu untuk menyimpan favorit.');
    }
    final current = state.valueOrNull ?? <String>{};
    final willAdd = !current.contains(itemId);

    // Optimistic: langsung perbarui UI.
    final optimistic = {...current};
    if (willAdd) {
      optimistic.add(itemId);
    } else {
      optimistic.remove(itemId);
    }
    state = AsyncData(optimistic);

    try {
      final repo = ref.read(wishlistRepositoryProvider);
      if (willAdd) {
        await repo.add(uid, itemId);
      } else {
        await repo.remove(uid, itemId);
      }
      // Segarkan daftar item wishlist (layar Wishlist).
      ref.invalidate(wishlistItemsProvider);
    } catch (e) {
      state = AsyncData(current); // rollback
      throw e.toAppException();
    }
  }
}

/// Cek cepat apakah sebuah item sudah di-wishlist.
@riverpod
bool isWishlisted(IsWishlistedRef ref, String itemId) {
  final ids = ref.watch(wishlistIdsProvider).valueOrNull ?? const <String>{};
  return ids.contains(itemId);
}

/// Daftar item lengkap yang di-wishlist (untuk layar Wishlist).
@riverpod
Future<List<Item>> wishlistItems(WishlistItemsRef ref) {
  final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (uid == null) return Future.value(const <Item>[]);
  return ref.watch(wishlistRepositoryProvider).fetchWishlistItems(uid);
}