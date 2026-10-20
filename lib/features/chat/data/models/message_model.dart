class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String itemId;
  final String? bookingId; // opsional: hanya untuk konteks booking
  final String message;
  final bool isRead;
  final DateTime timestamp;

  /// true bila pesan masih dalam proses kirim (optimistic update).
  final bool pending;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.itemId,
    this.bookingId,
    required this.message,
    required this.isRead,
    required this.timestamp,
    this.pending = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        senderId: json['sender_id'] as String,
        receiverId: json['receiver_id'] as String,
        itemId: json['item_id'] as String? ?? '',
        bookingId: json['booking_id'] as String?,
        message: json['message'] as String? ?? '',
        isRead: json['is_read'] as bool? ?? false,
        timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      );

  /// Payload untuk insert (id, is_read, timestamp di-set oleh DB).
  Map<String, dynamic> toInsert() => {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'item_id': itemId,
        if (bookingId != null) 'booking_id': bookingId,
        'message': message,
      };

  Message copyWith({String? id, bool? isRead, bool? pending}) => Message(
        id: id ?? this.id,
        senderId: senderId,
        receiverId: receiverId,
        itemId: itemId,
        bookingId: bookingId,
        message: message,
        isRead: isRead ?? this.isRead,
        timestamp: timestamp,
        pending: pending ?? this.pending,
      );
}