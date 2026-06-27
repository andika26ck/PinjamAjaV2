import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/item_card.dart';
import '../../providers/home_provider.dart';
import '../../providers/search_history_provider.dart';
import '../../providers/search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _pickQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    final notifier = ref.read(searchControllerProvider.notifier);
    notifier.setQuery(q);
    notifier.run();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);
    final filterCount = state.filters.activeCount;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: notifier.setQuery,
          onSubmitted: (_) => notifier.run(),
          decoration: InputDecoration(
            hintText: 'Cari barang...',
            border: InputBorder.none,
            suffixIcon: state.query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      notifier.setQuery('');
                    },
                  ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => showFilterBottomSheet(context),
              ),
              if (filterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: Text(
                      '$filterCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, SearchUiState state) {
    if (!state.hasSearched) {
      return _SuggestionsView(onPick: _pickQuery);
    }
    return state.results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            e is AppException ? e.message : 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) return const _EmptyResult();
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return ItemCard(
              item: item,
              onTap: () => context.push(AppRoutes.itemDetailPath(item.id)),
            );
          },
        );
      },
    );
  }
}

class _SuggestionsView extends ConsumerWidget {
  final void Function(String) onPick;
  const _SuggestionsView({required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    final cats = ref.watch(categoriesProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        history.maybeWhen(
          data: (list) => list.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Riwayat Pencarian',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              ref.read(searchHistoryProvider.notifier).clear(),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                    ...list.map(
                      (q) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.history,
                            color: AppColors.textTertiary),
                        title: Text(q),
                        trailing: IconButton(
                          icon: const Icon(Icons.north_west, size: 18),
                          onPressed: () => onPick(q),
                        ),
                        onTap: () => onPick(q),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
          orElse: () => const SizedBox.shrink(),
        ),
        const Text('Kategori Populer',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        cats.maybeWhen(
          data: (list) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: list
                .map((c) => ActionChip(
                      label: Text(c.name),
                      onPressed: () => onPick(c.name),
                    ))
                .toList(),
          ),
          orElse: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 64, color: AppColors.textTertiary),
              SizedBox(height: 12),
              Text('Tidak ada hasil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Coba kata kunci lain atau ubah filter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}