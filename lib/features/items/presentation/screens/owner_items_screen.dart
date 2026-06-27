import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/item.dart';
import '../../providers/add_edit_item_provider.dart';
import '../../providers/owner_items_provider.dart';
import '../../providers/owner_stats_provider.dart';
import 'add_edit_item_screen.dart';
import 'owner_item_stats_screen.dart';

class OwnerItemsScreen extends ConsumerWidget {
  const OwnerItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(ownerItemsProvider);
    final statsMap = ref.watch(ownerItemStatsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => <String, ItemMiniStat>{},
        );

    return DefaultTabController(
      length: OwnerItemTab.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Barang Saya'),
          bottom: TabBar(
            tabs: [
              for (final t in OwnerItemTab.values) Tab(text: t.label),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.ownerItemAdd),
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
        body: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(e is AppException ? e.message : 'Gagal memuat barang.'),
          ),
          data: (items) => TabBarView(
            children: [
              for (final tab in OwnerItemTab.values)
                _OwnerItemList(
                  items: items.where(tab.matches).toList(),
                  stats: statsMap,
                  onRefresh: () async {
                    ref.invalidate(ownerItemsProvider);
                    ref.invalidate(ownerItemStatsProvider);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerItemList extends ConsumerWidget {
  final List<Item> items;
  final Map<String, ItemMiniStat> stats;
  final Future<void> Function() onRefresh;
  const _OwnerItemList({
    required this.items,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.inventory_2_outlined,
                size: 64, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Center(
              child: Text('Belum ada barang di sini.',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          final stat = stats[item.id] ?? const ItemMiniStat();
          return Dismissible(
            key: ValueKey(item.id),
            background: _swipeBg(
              align: Alignment.centerLeft,
              color: AppColors.primary,
              icon: Icons.edit,
              label: 'Edit',
            ),
            secondaryBackground: _swipeBg(
              align: Alignment.centerRight,
              color: AppColors.error,
              icon: Icons.delete,
              label: 'Hapus',
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Swipe kanan -> Edit
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddEditItemScreen(item: item),
                ));
                return false;
              }
              // Swipe kiri -> Hapus (konfirmasi)
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Barang'),
                  content: Text('Hapus "${item.title}"? Tindakan ini '
                      'tidak bisa dibatalkan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (ok != true) return false;
              final success = await ref
                  .read(addEditItemControllerProvider.notifier)
                  .deleteItem(item.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barang dihapus.')),
                );
              }
              return success;
            },
            child: _OwnerItemCard(item: item, stat: stat),
          );
        },
      ),
    );
  }

  Widget _swipeBg({
    required Alignment align,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OwnerItemCard extends StatelessWidget {
  final Item item;
  final ItemMiniStat stat;
  const _OwnerItemCard({required this.item, required this.stat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OwnerItemStatsScreen(item: item),
      )),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: item.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const ColoredBox(
                                    color: AppColors.surfaceVariant),
                          )
                        : const ColoredBox(
                            color: AppColors.surfaceVariant,
                            child: Icon(Icons.image_outlined,
                                color: AppColors.textTertiary),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Formatters.rupiah(item.pricePerDay)}/hari',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _miniStat(Icons.event_note_outlined, 'Booking',
                    '${stat.totalBookings}'),
                _miniStat(Icons.payments_outlined, 'Bulan ini',
                    Formatters.rupiah(stat.revenueThisMonth)),
                _miniStat(Icons.star_rounded, 'Rating',
                    item.rating.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}