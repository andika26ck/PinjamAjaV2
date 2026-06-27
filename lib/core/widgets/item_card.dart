import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/models/item.dart';
import '../../features/wishlist/presentation/widgets/wishlist_button.dart'; // (+) wishlist
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

/// Kartu item reusable: dipakai di grid Home, list horizontal, & hasil search.
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  Color get _conditionColor => switch (item.condition) {
        ItemCondition.baru => AppColors.success,
        ItemCondition.sangatBaik => AppColors.info,
        ItemCondition.baik => AppColors.warning,
        ItemCondition.cukup => AppColors.textSecondary,
        null => AppColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  if (item.condition != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _badge(item.condition!.label),
                    ),
                  // (+) wishlist: tombol ♡ di pojok kanan atas thumbnail
                  Positioned(
                    top: 4,
                    right: 4,
                    child: WishlistButton(
                      itemId: item.id,
                      size: 20,
                      withBackground: true,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  if (item.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.secondary),
                      const SizedBox(width: 2),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.totalReviews})',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.rupiahPerDay(item.pricePerDay),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = item.thumbnailUrl;
    if (url == null) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(color: Colors.white),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.textTertiary),
      ),
    );
  }

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _conditionColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      );
}