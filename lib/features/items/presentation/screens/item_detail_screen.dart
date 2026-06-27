import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/item_card.dart';
import '../../../../data/models/item.dart';
import '../../../../data/models/review.dart';
import '../../../../data/models/user_profile.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart'; // (+) wishlist
import '../../providers/item_detail_provider.dart';
import '../widgets/review_card.dart';

Color conditionColor(ItemCondition? c) => switch (c) {
      ItemCondition.baru => AppColors.success,
      ItemCondition.sangatBaik => AppColors.info,
      ItemCondition.baik => AppColors.secondary,
      ItemCondition.cukup => AppColors.textTertiary,
      null => AppColors.textTertiary,
    };

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  bool _descExpanded = false;
  bool _showAllReviews = false;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(itemDetailProvider(widget.itemId));
    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is AppException ? e.message : 'Gagal memuat barang.',
          onRetry: () => ref.invalidate(itemDetailProvider(widget.itemId)),
        ),
        data: _buildBody,
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (b) => _BottomBar(item: b.item),
        orElse: () => null,
      ),
    );
  }

  Widget _buildBody(ItemDetailBundle b) {
    final item = b.item;
    final blocked = {
      for (final d in item.blockedDates) DateTime(d.year, d.month, d.day),
    };
    bool isBlocked(DateTime day) =>
        blocked.contains(DateTime(day.year, day.month, day.day));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 300,
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
          // (+) wishlist: tombol ♡ di kanan atas app bar (di atas foto)
          actions: [
            WishlistButton(
              itemId: item.id,
              size: 26,
              inactiveColor: Colors.white,
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _ImageCarousel(images: item.imageUrls),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleSection(item),
                const SizedBox(height: 16),
                _contactOwnerButton(),
                const SizedBox(height: 20),
                _priceSection(item),
                const SizedBox(height: 24),
                _descriptionSection(item),
                const SizedBox(height: 24),
                if (b.owner != null) _ownerSection(b.owner!),
                const SizedBox(height: 24),
                _availabilitySection(isBlocked),
                const SizedBox(height: 24),
                _reviewsSection(b.reviews),
                const SizedBox(height: 24),
                _similarSection(b.similar),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. Judul, badge kondisi, rating, lokasi
  Widget _titleSection(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (item.condition != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: conditionColor(item.condition).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.condition!.label,
                  style: TextStyle(
                    color: conditionColor(item.condition),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            const Icon(Icons.star_rounded,
                size: 18, color: AppColors.secondary),
            const SizedBox(width: 2),
            Text(
              '${item.rating.toStringAsFixed(1)} · ${item.totalReviews} ulasan',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        if (item.location != null && item.location!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.location!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // 3. Hubungi Owner
  Widget _contactOwnerButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO(Fase 5): buka ChatScreen dengan owner terkait.
          context.push(AppRoutes.chat);
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text('Hubungi Owner'),
      ),
    );
  }

  // 4. Harga + deposit
  Widget _priceSection(Item item) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            label: 'Harga sewa',
            value: Formatters.rupiah(item.pricePerDay),
            suffix: '/hari',
            highlight: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            label: 'Deposit',
            value: item.depositAmount > 0
                ? Formatters.rupiah(item.depositAmount)
                : 'Tanpa deposit',
          ),
        ),
      ],
    );
  }

  // 5. Deskripsi (collapsible)
  Widget _descriptionSection(Item item) {
    final desc = item.description;
    final isLong = desc.length > 160;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskripsi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          desc.isEmpty ? 'Tidak ada deskripsi.' : desc,
          maxLines: (!isLong || _descExpanded) ? null : 4,
          overflow: (!isLong || _descExpanded)
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        if (isLong)
          TextButton(
            onPressed: () => setState(() => _descExpanded = !_descExpanded),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(_descExpanded ? 'Lebih sedikit' : 'Selengkapnya'),
          ),
      ],
    );
  }

  // 6. Info Owner
  Widget _ownerSection(UserProfile owner) {
    final avatar = owner.avatarUrl;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: (avatar != null && avatar.isNotEmpty)
                ? CachedNetworkImageProvider(avatar)
                : null,
            child: (avatar == null || avatar.isEmpty)
                ? const Icon(Icons.person, color: AppColors.textTertiary)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.name?.isNotEmpty == true ? owner.name! : 'Pemilik',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '⭐ ${owner.rating.toStringAsFixed(1)} · '
                  '${owner.totalTransactions} transaksi',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO(Fase 6): buka profil publik owner.
              context.push(AppRoutes.profile);
            },
            child: const Text('Lihat Profil'),
          ),
        ],
      ),
    );
  }

  // 7. Kalender ketersediaan
  Widget _availabilitySection(bool Function(DateTime) isBlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ketersediaan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Tanggal merah = tidak tersedia',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(8),
          child: TableCalendar<void>(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.horizontalSwipe,
            onPageChanged: (d) => _focusedDay = d,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) =>
                  isBlocked(day) ? _blockedCell(day) : null,
              todayBuilder: (context, day, _) =>
                  isBlocked(day) ? _blockedCell(day) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _blockedCell(DateTime day) => Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: AppColors.error,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      );

  // 8. Ulasan
  Widget _reviewsSection(List<Review> reviews) {
    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Ulasan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Belum ada ulasan untuk barang ini.',
              style: TextStyle(color: AppColors.textTertiary)),
        ],
      );
    }
    final shown = _showAllReviews ? reviews : reviews.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ulasan (${reviews.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        ...shown.map((r) => ReviewCard(review: r)),
        if (reviews.length > 3)
          TextButton(
            onPressed: () =>
                setState(() => _showAllReviews = !_showAllReviews),
            child: Text(_showAllReviews
                ? 'Sembunyikan'
                : 'Lihat semua (${reviews.length})'),
          ),
      ],
    );
  }

  // 9. Barang serupa
  Widget _similarSection(List<Item> similar) {
    if (similar.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Barang Serupa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final it = similar[i];
              return SizedBox(
                width: 170,
                child: ItemCard(
                  item: it,
                  onTap: () =>
                      context.push(AppRoutes.itemDetailPath(it.id)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Bottom bar sticky
class _BottomBar extends StatelessWidget {
  final Item item;
  const _BottomBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Harga sewa',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  '${Formatters.rupiah(item.pricePerDay)}/hari',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Fase 4: BookingScreen membaca path param sebagai item_id.
                context.push(AppRoutes.bookingPath(item.id), extra: item);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 48),
              ),
              child: const Text('Sewa Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final bool highlight;
  const _InfoTile({
    required this.label,
    required this.value,
    this.suffix,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
              ),
              children: [
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.image_outlined,
              size: 64, color: AppColors.textTertiary),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: widget.images[i],
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: AppColors.surfaceVariant),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColors.textTertiary),
            ),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  width: active ? 20 : 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white70,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}