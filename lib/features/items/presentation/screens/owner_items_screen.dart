import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
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
                await _openEdit(context, item);
                return false;
              }
              return _confirmAndDelete(context, ref, item);
            },
            child: _OwnerItemCard(
              item: item,
              stat: stat,
              onEdit: () => _openEdit(context, item),
              onDelete: () => _confirmAndDelete(context, ref, item),
              onToggleActive: () => _toggleActive(context, ref, item),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, Item item) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddEditItemScreen(item: item),
    ));
  }

  Future<bool> _confirmAndDelete(
      BuildContext context, WidgetRef ref, Item item) async {
    final controller = ref.read(addEditItemControllerProvider.notifier);

    // Lindungi riwayat & harga booking lama: jika masih ada booking berjalan,
    // jangan hapus permanen. Tawarkan nonaktifkan saja.
    final hasActive = await controller.itemHasActiveBookings(item.id);
    if (!context.mounted) return false;

    if (hasActive) {
      final nonaktif = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tidak bisa dihapus'),
          content: Text(
              'Barang "${item.title}" masih punya booking berjalan. Demi '
              'menjaga riwayat & harga sewa penyewa, barang tidak bisa '
              'dihapus permanen.\n\nNonaktifkan saja? Barang tak akan muncul '
              'untuk penyewa baru, tapi booking lama tetap aman.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Nonaktifkan'),
            ),
          ],
        ),
      );
      if (nonaktif != true) return false;
      final ok = await controller.setItemStatus(
          item.id, AppConstants.itemStatusInactive);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang dinonaktifkan.')),
        );
      }
      return false; // jangan dismiss; item pindah ke tab "Nonaktif"
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Hapus "${item.title}"? Tindakan ini tidak bisa '
            'dibatalkan.'),
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
    if (ok != true) return false;
    final success = await controller.deleteItem(item.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang dihapus.')),
      );
    }
    return success;
  }

  Future<void> _toggleActive(
      BuildContext context, WidgetRef ref, Item item) async {
    final controller = ref.read(addEditItemControllerProvider.notifier);
    final activate = item.status == AppConstants.itemStatusInactive;
    final ok = await controller.setItemStatus(
      item.id,
      activate
          ? AppConstants.itemStatusAvailable
          : AppConstants.itemStatusInactive,
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              activate ? 'Barang diaktifkan.' : 'Barang dinonaktifkan.'),
        ),
      );
    }
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  const _OwnerItemCard({
    required this.item,
    required this.stat,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textTertiary),
                  tooltip: 'Aksi',
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'toggle') onToggleActive();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) {
                    final inactive =
                        item.status == AppConstants.itemStatusInactive;
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: ListTile(
                          leading: Icon(inactive
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          title: Text(inactive ? 'Aktifkan' : 'Nonaktifkan'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: AppColors.error),
                          title: Text('Hapus',
                              style: TextStyle(color: AppColors.error)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ];
                  },
                ),
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