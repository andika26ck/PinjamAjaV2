import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/item_card.dart';
import '../../../../data/models/item.dart';
import '../../../../data/models/user_profile.dart';
import '../../../report/presentation/widgets/report_sheet.dart';
import '../../../review/presentation/widgets/rating_summary.dart';
import '../../../review/presentation/widgets/review_tile.dart';
import '../../data/profile_repository.dart';
import '../../providers/profile_provider.dart';

/// Filter tab barang di profil publik.
enum _ItemFilter { semua, tersedia }

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(userId));
    final isSelf = ref.watch(myProfileProvider)?.id == userId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        actions: [
          if (!isSelf)
            ReportButton(
              targetType: ReportTargetType.user,
              targetId: userId,
            ),
          IconButton(
            tooltip: 'Bagikan profil',
            onPressed: () => _shareProfile(async.valueOrNull?.profile),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(publicProfileProvider(userId)),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(publicProfileProvider(userId)),
          child: _Body(data: data, isSelf: isSelf),
        ),
      ),
    );
  }

  void _shareProfile(UserProfile? profile) {
    final name =
        profile?.name?.isNotEmpty == true ? profile!.name! : 'pengguna ini';
    Share.share(
      'Lihat profil $name di PinjamAja 👀\npinjamaja://user/$userId',
      subject: 'Profil $name — PinjamAja',
    );
  }
}

class _Body extends StatefulWidget {
  final PublicProfileData data;
  final bool isSelf;
  const _Body({required this.data, required this.isSelf});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  _ItemFilter _filter = _ItemFilter.semua;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final profile = data.profile;
    final isOwner = profile.role == UserRole.owner;

    final List<Item> shownItems = switch (_filter) {
      _ItemFilter.semua => data.items,
      _ItemFilter.tersedia => data.availableItems,
    };

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _PublicHeader(
          profile: profile,
          isSelf: widget.isSelf,
          rating: data.computedRating,
          reviewsCount: data.reviewsCount,
          transactionsCount: data.transactionsCount,
          onContact: () => _contactOwner(data),
        ),
        if (isOwner) ...[
          _ItemsHeader(
            filter: _filter,
            semuaCount: data.items.length,
            tersediaCount: data.availableItems.length,
            onChanged: (f) => setState(() => _filter = f),
          ),
          if (shownItems.isEmpty)
            _EmptyHint(_filter == _ItemFilter.tersedia
                ? 'Belum ada barang yang tersedia.'
                : 'Belum ada barang.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: shownItems.length,
              itemBuilder: (_, i) {
                final item = shownItems[i];
                return ItemCard(
                  item: item,
                  onTap: () => context.push(AppRoutes.itemDetailPath(item.id)),
                );
              },
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

  void _contactOwner(PublicProfileData data) {
    // Chat berbasis (item + lawan bicara). Pakai barang yang tersedia sebagai
    // konteks; jika tak ada, pakai barang apa pun milik pemilik.
    final anchor = data.availableItems.isNotEmpty
        ? data.availableItems.first
        : (data.items.isNotEmpty ? data.items.first : null);
    if (anchor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Pemilik belum punya barang untuk ditanyakan. Coba lagi nanti.'),
        ),
      );
      return;
    }
    context.push(AppRoutes.chatRoomPath(anchor.id, data.profile.id));
  }
}

class _PublicHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isSelf;
  final double rating;
  final int reviewsCount;
  final int transactionsCount;
  final VoidCallback onContact;
  const _PublicHeader({
    required this.profile,
    required this.isSelf,
    required this.rating,
    required this.reviewsCount,
    required this.transactionsCount,
    required this.onContact,
  });

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String? get _memberSince {
    final d = profile.createdAt;
    if (d == null) return null;
    return 'Bergabung ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = profile.avatarUrl;
    final memberSince = _memberSince;
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
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _Chip(
                label: profile.role?.label ?? 'Pengguna',
                color: AppColors.primary,
                icon: Icons.person_outline,
              ),
              if (profile.isVerified)
                const _Chip(
                  label: 'Terverifikasi',
                  color: AppColors.success,
                  icon: Icons.verified_outlined,
                )
              else
                const _Chip(
                  label: 'Belum terverifikasi',
                  color: AppColors.textTertiary,
                  icon: Icons.gpp_maybe_outlined,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: 2),
              Text(
                  reviewsCount == 0
                      ? 'Belum ada rating'
                      : '${rating.toStringAsFixed(1)} ($reviewsCount ulasan)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 10),
              const Icon(Icons.swap_horiz_rounded,
                  size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 2),
              Text('$transactionsCount transaksi',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          if (memberSince != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(memberSince,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ],
          if (!isSelf) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Hubungi'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Chip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  final _ItemFilter filter;
  final int semuaCount;
  final int tersediaCount;
  final ValueChanged<_ItemFilter> onChanged;
  const _ItemsHeader({
    required this.filter,
    required this.semuaCount,
    required this.tersediaCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Barang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              ChoiceChip(
                label: Text('Semua ($semuaCount)'),
                selected: filter == _ItemFilter.semua,
                onSelected: (_) => onChanged(_ItemFilter.semua),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Tersedia ($tersediaCount)'),
                selected: filter == _ItemFilter.tersedia,
                onSelected: (_) => onChanged(_ItemFilter.tersedia),
              ),
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