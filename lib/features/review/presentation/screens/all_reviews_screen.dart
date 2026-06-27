import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/review_repository.dart';
import '../../providers/review_provider.dart';
import '../widgets/rating_summary.dart';
import '../widgets/review_tile.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  const AllReviewsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  // 0 = Semua, 1..5 = filter bintang.
  int _filter = 0;

  List<ReviewWithAuthor> _apply(List<ReviewWithAuthor> all) {
    if (_filter == 0) return all;
    return all.where((r) => r.review.rating == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(itemReviewsProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Ulasan')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          onRetry: () => ref.invalidate(itemReviewsProvider(widget.itemId)),
        ),
        data: (all) {
          if (all.isEmpty) return const _EmptyState();
          final filtered = _apply(all);

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(itemReviewsProvider(widget.itemId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RatingSummary(reviews: all),
                const SizedBox(height: 16),
                _FilterChips(
                  all: all,
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
                const SizedBox(height: 8),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Belum ada ulasan untuk filter ini.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (r) => Column(
                      children: [
                        ReviewTile(data: r),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.all,
    required this.selected,
    required this.onSelected,
  });

  final List<ReviewWithAuthor> all;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    int countFor(int star) =>
        all.where((r) => r.review.rating == star).length;

    final chips = <Widget>[
      _chip(label: 'Semua (${all.length})', value: 0),
      for (var s = 5; s >= 1; s--)
        _chip(label: '$s ⭐ (${countFor(s)})', value: s),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in chips)
            Padding(padding: const EdgeInsets.only(right: 8), child: c),
        ],
      ),
    );
  }

  Widget _chip({required String label, required int value}) {
    final isSel = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      onSelected: (_) => onSelected(value),
      showCheckmark: false,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.reviews_outlined,
              size: 56, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Belum ada ulasan',
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Jadilah yang pertama memberi ulasan.',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text('Gagal memuat ulasan.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}