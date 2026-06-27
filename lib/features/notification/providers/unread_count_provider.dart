import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_provider.dart';

part 'unread_count_provider.g.dart';

/// Jumlah notifikasi belum dibaca — dipakai untuk badge di bottom nav.
@riverpod
int notificationUnreadCount(NotificationUnreadCountRef ref) {
  final async = ref.watch(notificationListProvider);
  return async.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
}