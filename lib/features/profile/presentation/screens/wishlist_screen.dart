import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/item_card.dart';
import '../../../wishlist/providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wishlistItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(wishlistItemsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState.noItems(
              onAction: () => ref.invalidate(wishlistItemsProvider),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(wishlistIdsProvider);
              ref.invalidate(wishlistItemsProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return GestureDetector(
                  onLongPress: () => _confirmRemove(context, ref, item.id,
                      item.title),
                  child: ItemCard(
                    item: item,
                    onTap: () =>
                        context.push(AppRoutes.itemDetailPath(item.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref,
      String itemId, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus dari Favorit'),
        content: Text('Hapus “$title” dari daftar favoritmu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(wishlistIdsProvider.notifier).toggle(itemId);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Gagal menghapus favorit.'),
                backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}