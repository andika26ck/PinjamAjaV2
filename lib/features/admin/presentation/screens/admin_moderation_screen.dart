import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/item.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminModerationScreen extends ConsumerStatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  ConsumerState<AdminModerationScreen> createState() =>
      _AdminModerationScreenState();
}

class _AdminModerationScreenState extends ConsumerState<AdminModerationScreen> {
  String? _filter; // null = semua | ok | flagged | removed

  @override
  Widget build(BuildContext context) {
    final itemsAsync =
        ref.watch(adminModerationItemsProvider(moderationStatus: _filter));
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.moderation,
      title: 'Moderasi Barang',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Semua', null),
                  const SizedBox(width: 8),
                  _filterChip('Normal', 'ok'),
                  const SizedBox(width: 8),
                  _filterChip('Ditandai', 'flagged'),
                  const SizedBox(width: 8),
                  _filterChip('Dihapus', 'removed'),
                ],
              ),
            ),
          ),
          if (isWorking) const LinearProgressIndicator(),
          Expanded(
            child: itemsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: '$e',
                onRetry: () =>
                    ref.invalidate(adminModerationItemsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada barang ditemukan.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminModerationItemsProvider);
                    await ref.read(adminModerationItemsProvider(
                            moderationStatus: _filter)
                        .future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ItemTile(
                      item: items[i],
                      onModerate: (status) =>
                          _moderate(items[i], status),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Future<void> _moderate(Item item, String status) async {
    String? note;
    if (status != 'ok') {
      note = await _askNote(
        status == 'removed' ? 'Hapus barang' : 'Tandai barang',
      );
      if (note == null) return; // batal
    }
    final ok = await ref.read(adminControllerProvider.notifier).moderateItem(
          itemId: item.id,
          status: status,
          note: (note == null || note.isEmpty) ? null : note,
        );
    if (!mounted) return;
    final err = ref.read(adminControllerProvider).error;
    final msg = switch (status) {
      'ok' => 'Barang \"${item.title}\" dipulihkan.',
      'flagged' => 'Barang \"${item.title}\" ditandai.',
      'removed' => 'Barang \"${item.title}\" dihapus.',
      _ => 'Status diperbarui.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? msg : 'Gagal: ${err ?? 'terjadi kesalahan'}'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  Future<String?> _askNote(String title) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Catatan moderasi (opsional)…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }
}

String _modLabel(String s) => switch (s) {
      'ok' => 'Normal',
      'flagged' => 'Ditandai',
      'removed' => 'Dihapus',
      _ => s,
    };

Color _modColor(String s) => switch (s) {
      'ok' => AppColors.success,
      'flagged' => AppColors.secondary,
      'removed' => AppColors.error,
      _ => AppColors.textTertiary,
    };

class _ItemTile extends StatelessWidget {
  final Item item;
  final void Function(String status) onModerate;
  const _ItemTile({required this.item, required this.onModerate});

  @override
  Widget build(BuildContext context) {
    final thumb = item.thumbnailUrl;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (thumb != null && thumb.isNotEmpty)
                    ? Image.network(
                        thumb,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _thumbPlaceholder(),
                      )
                    : _thumbPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.rupiahPerDay(item.pricePerDay),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Badge(_modLabel(item.moderationStatus),
                            _modColor(item.moderationStatus)),
                        _Badge('Status: ${item.status}',
                            AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.moderationNote != null &&
              item.moderationNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan: ${item.moderationNote}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 4,
              children: [
                if (item.moderationStatus != 'ok')
                  TextButton.icon(
                    onPressed: () => onModerate('ok'),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Pulihkan'),
                  ),
                if (item.moderationStatus != 'flagged')
                  TextButton.icon(
                    onPressed: () => onModerate('flagged'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary),
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Tandai'),
                  ),
                if (item.moderationStatus != 'removed')
                  TextButton.icon(
                    onPressed: () => onModerate('removed'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.error),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        width: 64,
        height: 64,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.inventory_2_outlined,
            color: AppColors.textTertiary),
      );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}