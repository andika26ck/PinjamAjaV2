import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/booking_repository.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatShortDate(DateTime? d) =>
    d == null ? '-' : '${d.day} ${_months[d.month - 1]} ${d.year}';

String bookingStatusLabel(String status) => switch (status) {
      'pending' => 'Menunggu',
      'confirmed' => 'Dikonfirmasi',
      'active' => 'Aktif',
      'completed' => 'Selesai',
      'cancelled' => 'Dibatalkan',
      _ => status,
    };

Color bookingStatusColor(String status) => switch (status) {
      'pending' => AppColors.statusPending,
      'confirmed' => AppColors.statusActive,
      'active' => AppColors.primary,
      'completed' => AppColors.statusCompleted,
      'cancelled' => AppColors.statusCancelled,
      _ => AppColors.textTertiary,
    };

class BookingStatusBadge extends StatelessWidget {
  final String status;
  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = bookingStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bookingStatusLabel(status),
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingView view;
  final VoidCallback onTap;
  const BookingCard({super.key, required this.view, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final b = view.booking;
    final item = view.item;
    final thumb = item?.thumbnailUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: thumb != null
                    ? CachedNetworkImage(
                        imageUrl: thumb,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const ColoredBox(
                            color: AppColors.surfaceVariant),
                      )
                    : const ColoredBox(
                        color: AppColors.surfaceVariant,
                        child: Icon(Icons.image_outlined,
                            color: AppColors.textTertiary),
                      ),
              ),
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
                          item?.title ?? 'Barang',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BookingStatusBadge(status: b.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${formatShortDate(b.startDate)} - ${formatShortDate(b.endDate)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.rupiah(b.totalPrice),
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}