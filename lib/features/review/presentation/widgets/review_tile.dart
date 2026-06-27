import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../data/review_repository.dart';
import 'star_display.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.data});

  final ReviewWithAuthor data;

  @override
  Widget build(BuildContext context) {
    final r = data.review;
    final name = (data.authorName?.trim().isNotEmpty ?? false)
        ? data.authorName!.trim()
        : 'Pengguna';
    final avatar = data.authorAvatar;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.border,
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? CachedNetworkImageProvider(avatar)
                    : null,
                child: (avatar == null || avatar.isEmpty)
                    ? Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StarDisplay(rating: r.rating.toDouble(), size: 14),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(r.createdAt ?? DateTime.now(), locale: 'id'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((r.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text((r.comment ?? '').trim(), style: const TextStyle(height: 1.4)),
          ],
        ],
      ),
    );
  }
}