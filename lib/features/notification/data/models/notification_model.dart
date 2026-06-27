enum AppNotificationType {
  bookingRequest('booking_request'),
  bookingConfirmed('booking_confirmed'),
  bookingCancelled('booking_cancelled'),
  bookingCompleted('booking_completed'),
  newMessage('new_message'),
  newReview('new_review'),
  paymentSuccess('payment_success'),
  unknown('unknown');

  final String value;
  const AppNotificationType(this.value);

  static AppNotificationType fromValue(String? v) =>
      AppNotificationType.values.firstWhere(
        (e) => e.value == v,
        orElse: () => AppNotificationType.unknown,
      );
}

class AppNotification {
  final String id;
  final String userId;
  final AppNotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  String? get bookingId => data['booking_id'] as String?;
  String? get itemId => data['item_id'] as String?;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: AppNotificationType.fromValue(json['type'] as String?),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}