import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Empty state konsisten untuk seluruh aplikasi.
/// Gunakan factory siap pakai: `EmptyState.noItems()`, dll.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.noItems({VoidCallback? onAction}) => EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Belum ada barang',
        subtitle: 'Barang yang tersedia akan muncul di sini.',
        actionLabel: onAction != null ? 'Muat ulang' : null,
        onAction: onAction,
      );

  factory EmptyState.noBookings({VoidCallback? onAction}) => EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada booking',
        subtitle: 'Sewa barang pertamamu dan booking akan tampil di sini.',
        actionLabel: onAction != null ? 'Jelajahi barang' : null,
        onAction: onAction,
      );

  factory EmptyState.noMessages({VoidCallback? onAction}) => EmptyState(
        icon: Icons.forum_outlined,
        title: 'Belum ada percakapan',
        subtitle: 'Chat dengan pemilik atau penyewa akan muncul di sini.',
        actionLabel: onAction != null ? 'Muat ulang' : null,
        onAction: onAction,
      );

  factory EmptyState.noNotifications({VoidCallback? onAction}) => EmptyState(
        icon: Icons.notifications_none_outlined,
        title: 'Belum ada notifikasi',
        subtitle: 'Pemberitahuan terbaru akan tampil di sini.',
        actionLabel: onAction != null ? 'Muat ulang' : null,
        onAction: onAction,
      );

  factory EmptyState.noSearchResults(String query, {VoidCallback? onAction}) =>
      EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Tidak ada hasil',
        subtitle: query.trim().isEmpty
            ? 'Coba kata kunci lain.'
            : 'Tidak ditemukan hasil untuk “$query”.',
        actionLabel: onAction != null ? 'Reset pencarian' : null,
        onAction: onAction,
      );

  factory EmptyState.noReviews({VoidCallback? onAction}) => EmptyState(
        icon: Icons.reviews_outlined,
        title: 'Belum ada ulasan',
        subtitle: 'Ulasan dari penyewa akan tampil di sini.',
        actionLabel: onAction != null ? 'Muat ulang' : null,
        onAction: onAction,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textTertiary),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}