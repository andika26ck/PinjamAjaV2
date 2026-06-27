import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/item_card.dart';
import '../../../../data/models/user_profile.dart';
import '../../../review/presentation/widgets/rating_summary.dart';
import '../../../review/presentation/widgets/review_tile.dart';
import '../../data/profile_repository.dart';
import '../../providers/profile_provider.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(publicProfileProvider(userId)),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(publicProfileProvider(userId)),
          child: _Body(data: data),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PublicProfileData data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
    final isOwner = profile.role == UserRole.owner;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _PublicHeader(profile: profile),
        if (isOwner) ...[
          const _SectionTitle('Barang Aktif'),
          if (data.activeItems.isEmpty)
            const _EmptyHint('Belum ada barang aktif.')
          else
            SizedBox(
              height: 236,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.activeItems.length,
                itemBuilder: (_, i) {
                  final item = data.activeItems[i];
                  return SizedBox(
                    width: 168,
                    child: ItemCard(
                      item: item,
                      onTap: () => context
                          .push(AppRoutes.itemDetailPath(item.id)),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
              ),
            ),
        ],
        const _SectionTitle('Ulasan Diterima'),
        if (data.reviews.isEmpty)
          const _EmptyHint('Belum ada ulasan.')
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RatingSummary(reviews: data.reviews),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: data.reviews.length,
            itemBuilder: (_, i) => ReviewTile(data: data.reviews[i]),
          ),
        ],
      ],
    );
  }
}

class _PublicHeader extends StatelessWidget {
  final UserProfile profile;
  const _PublicHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avatar = profile.avatarUrl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      color: AppColors.surface,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? CachedNetworkImageProvider(avatar)
                    : null,
                child: (avatar == null || avatar.isEmpty)
                    ? Text(
                        (profile.name ?? '?').characters.first.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary),
                      )
                    : null,
              ),
              if (profile.isVerified)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.verified,
                        size: 20, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.name?.isNotEmpty == true ? profile.name! : 'Pengguna',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.role?.label ?? 'Pengguna',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: 2),
              Text(profile.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 8),
              Text('${profile.totalTransactions} transaksi',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(text,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(text,
          style: const TextStyle(color: AppColors.textTertiary)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          const Text('Gagal memuat profil.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}