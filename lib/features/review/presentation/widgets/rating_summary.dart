import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/review_repository.dart';
import 'star_display.dart';

/// Ringkasan: rata-rata besar + bar distribusi bintang 5→1.
class RatingSummary extends StatelessWidget {
  const RatingSummary({super.key, required this.reviews});

  final List<ReviewWithAuthor> reviews;

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    final avg = total == 0
        ? 0.0
        : reviews.map((r) => r.review.rating).reduce((a, b) => a + b) / total;

    // Hitung jumlah per bintang (rating disimpan sebagai double).
    final counts = <int, int>{for (var s = 1; s <= 5; s++) s: 0};
    for (final r in reviews) {
      final star = r.review.rating.round();
      if (star >= 1 && star <= 5) counts[star] = (counts[star] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kolom rata-rata.
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              StarDisplay(rating: avg, size: 16),
              const SizedBox(height: 4),
              Text(
                '$total ulasan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Bar distribusi.
          Expanded(
            child: Column(
              children: [
                for (var s = 5; s >= 1; s--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('$s', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star_rounded,
                            size: 12, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : (counts[s]! / total),
                              minHeight: 8,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${counts[s]}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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