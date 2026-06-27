import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/notification_model.dart';
import '../data/notification_repository.dart';
import '../data/supabase_notification_repository.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(
        NotificationRepositoryRef ref) =>
    SupabaseNotificationRepository(ref.watch(supabaseClientProvider));

/// Daftar notifikasi user (terbaru di atas) + auto-refresh realtime.
@Riverpod(keepAlive: true)
class NotificationList extends _$NotificationList {
  RealtimeChannel? _channel;

  @override
  Future<List<AppNotification>> build() async {
    ref.onDispose(() {
      final ch = _channel;
      if (ch != null) {
        ref.read(supabaseClientProvider).removeChannel(ch);
      }
    });
    _subscribe();
    return ref.read(notificationRepositoryProvider).fetchNotifications();
  }

  void _subscribe() {
    final client = ref.read(supabaseClientProvider);
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    _channel = client
        .channel('public:notifications:$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    _patch((n) => n.id == id ? _copyRead(n) : n);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    _patch(_copyRead);
  }

  Future<void> remove(String id) async {
    final prev = state.valueOrNull ?? const <AppNotification>[];
    state = AsyncData(prev.where((n) => n.id != id).toList());
    try {
      await ref.read(notificationRepositoryProvider).deleteNotification(id);
    } catch (_) {
      state = AsyncData(prev); // rollback bila gagal
    }
  }

  void _patch(AppNotification Function(AppNotification) f) {
    final list = state.valueOrNull;
    if (list == null) return;
    state = AsyncData(list.map(f).toList());
  }

  AppNotification _copyRead(AppNotification n) => AppNotification(
        id: n.id,
        userId: n.userId,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        isRead: true,
        createdAt: n.createdAt,
      );
}