import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          async.maybeWhen(
            data: (list) => list.any((n) => !n.isRead)
                ? TextButton(
                    onPressed: notifier.markAllRead,
                    child: const Text('Tandai semua'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationListProvider.future),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text(e is AppException
                    ? e.message
                    : 'Gagal memuat notifikasi.'),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: AppColors.textTertiary),
                  SizedBox(height: 12),
                  Center(
                    child: Text('Belum ada notifikasi.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = items[i];
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white),
                  ),
                  onDismissed: (_) => notifier.remove(n.id),
                  child: _NotificationTile(
                    notification: n,
                    onTap: () {
                      notifier.markRead(n.id);
                      _handleTap(context, n);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, AppNotification n) {
    switch (n.type) {
      case AppNotificationType.newMessage:
        final bid = n.bookingId;
        if (bid != null) context.push(AppRoutes.chatRoomPath(bid));
        break;
      case AppNotificationType.bookingRequest:
      case AppNotificationType.bookingConfirmed:
      case AppNotificationType.bookingCancelled:
      case AppNotificationType.bookingCompleted:
      case AppNotificationType.paymentSuccess:
      case AppNotificationType.newReview:
        final bid = n.bookingId;
        if (bid != null) context.push(AppRoutes.bookingDetailPath(bid));
        break;
      case AppNotificationType.unknown:
        break;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationTile(
      {required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, color) = _visual(n.type);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: n.isRead ? null : AppColors.primary.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
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
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n.body,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeago.format(n.createdAt, locale: 'id'),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _visual(AppNotificationType type) => switch (type) {
        AppNotificationType.bookingRequest => (
            Icons.add_box_outlined,
            AppColors.statusPending
          ),
        AppNotificationType.bookingConfirmed => (
            Icons.check_circle_outline,
            AppColors.statusActive
          ),
        AppNotificationType.bookingCancelled => (
            Icons.cancel_outlined,
            AppColors.statusCancelled
          ),
        AppNotificationType.bookingCompleted => (
            Icons.task_alt,
            AppColors.statusCompleted
          ),
        AppNotificationType.newMessage => (
            Icons.chat_bubble_outline,
            AppColors.primary
          ),
        AppNotificationType.newReview => (
            Icons.star_outline,
            AppColors.secondary
          ),
        AppNotificationType.paymentSuccess => (
            Icons.payments_outlined,
            AppColors.success
          ),
        AppNotificationType.unknown => (
            Icons.notifications_outlined,
            AppColors.textTertiary
          ),
      };
}