import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/item_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/home_repository.dart';
import '../../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(nearbyItemsProvider);
    ref.invalidate(popularItemsProvider);
    await Future.wait([
      ref.read(categoriesProvider.future),
      ref.read(nearbyItemsProvider.future),
      ref.read(popularItemsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appAuthProvider).profile;
    final name = profile?.name ?? 'Sobat';
    final avatarUrl = profile?.avatarUrl;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              titleSpacing: 16,
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo,',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        Text('$name! 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.notifications),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  const SizedBox(width: 4),
                  _Avatar(url: avatarUrl, name: name),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _SearchBar(onTap: () => context.push(AppRoutes.search)),
            ),
            const SliverToBoxAdapter(child: _CategoriesSection()),
            const SliverToBoxAdapter(
              child: _SectionHeader(
                  title: 'Terdekat dari Kamu', trailing: _SortDropdown()),
            ),
            const _NearbyGrid(),
            const SliverToBoxAdapter(
                child: _SectionHeader(title: 'Populer Minggu Ini')),
            const SliverToBoxAdapter(child: _PopularList()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hasImage = url != null && url!.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: hasImage ? CachedNetworkImageProvider(url!) : null,
      child: hasImage
          ? null
          : Text(initial,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textTertiary),
              SizedBox(width: 10),
              Text('Cari barang untuk disewa...',
                  style: TextStyle(color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _SortDropdown extends ConsumerWidget {
  const _SortDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(homeFilterControllerProvider).sort;
    return DropdownButtonHideUnderline(
      child: DropdownButton<HomeSort>(
        value: sort,
        isDense: true,
        borderRadius: BorderRadius.circular(12),
        items: HomeSort.values
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.label, style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: (s) {
          if (s != null) {
            ref.read(homeFilterControllerProvider.notifier).setSort(s);
          }
        },
      ),
    );
  }
}

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider);
    final activeId = ref.watch(homeFilterControllerProvider).categoryId;
    final notifier = ref.read(homeFilterControllerProvider.notifier);

    return cats.when(
      loading: () =>
          const SizedBox(height: 96, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) => SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          itemCount: list.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, i) {
            if (i == 0) {
              return _CategoryChip(
                label: 'Semua',
                selected: activeId == null,
                onTap: () => notifier.selectCategory(null),
              );
            }
            final c = list[i - 1];
            return _CategoryChip(
              label: c.name,
              iconUrl: c.iconUrl,
              selected: activeId == c.id,
              onTap: () => notifier.selectCategory(c.id),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? iconUrl;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    this.iconUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    final hasIcon = iconUrl != null && iconUrl!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: hasIcon
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CachedNetworkImage(
                        imageUrl: iconUrl!,
                        color: fg,
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.category_outlined, color: fg),
                      ),
                    )
                  : Icon(Icons.category_outlined, color: fg),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyGrid extends ConsumerWidget {
  const _NearbyGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(nearbyItemsProvider);
    return items.when(
      loading: () => const SliverToBoxAdapter(child: _GridShimmer()),
      error: (e, _) => SliverToBoxAdapter(
        child: _ErrorBox(
          message: e is AppException ? e.message : 'Gagal memuat barang.',
          onRetry: () => ref.invalidate(nearbyItemsProvider),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const SliverToBoxAdapter(
            child: _InfoBox(text: 'Belum ada barang di sekitarmu.'),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final item = list[i];
                return ItemCard(
                  item: item,
                  onTap: () =>
                      context.push(AppRoutes.itemDetailPath(item.id)),
                );
              },
              childCount: list.length,
            ),
          ),
        );
      },
    );
  }
}

class _PopularList extends ConsumerWidget {
  const _PopularList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(popularItemsProvider);
    return SizedBox(
      height: 255,
      child: items.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) =>
              const SizedBox(width: 180, child: _CardShimmer()),
        ),
        error: (_, __) => const Center(
            child: Text('Gagal memuat item populer.',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
                child: Text('Belum ada item populer.',
                    style: TextStyle(color: AppColors.textSecondary)));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final item = list[i];
              return SizedBox(
                width: 180,
                child: ItemCard(
                  item: item,
                  onTap: () =>
                      context.push(AppRoutes.itemDetailPath(item.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
          children: List.generate(4, (_) => const _CardShimmer()),
        ),
      );
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      );
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
            child: Text(text,
                style: const TextStyle(color: AppColors.textSecondary))),
      );
}