import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/notification_model.dart';
import 'notification_repository.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _client;
  SupabaseNotificationRepository(this._client);

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Sesi tidak ditemukan.');
    return id;
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    final rows = (data as List).cast<Map<String, dynamic>>();
    return rows.map(AppNotification.fromJson).toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', id);
  }

  @override
  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _uid)
        .eq('is_read', false);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _client.from('notifications').delete().eq('id', id);
  }
}