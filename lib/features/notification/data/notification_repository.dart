import 'models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> deleteNotification(String id);
}