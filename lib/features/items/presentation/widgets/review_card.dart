import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  String get _initial {
    final n = review.reviewerName?.trim() ?? '';
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = review.reviewerAvatarUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: (avatar != null && avatar.isNotEmpty)
                ? CachedNetworkImageProvider(avatar)
                : null,
            child: (avatar == null || avatar.isEmpty)
                ? Text(_initial,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName?.isNotEmpty == true
                            ? review.reviewerName!
                            : 'Pengguna',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      _fmtDate(review.createdAt),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < review.rating.round();
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    );
                  }),
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    review.comment!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}