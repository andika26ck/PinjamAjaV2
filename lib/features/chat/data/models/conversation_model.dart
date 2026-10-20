/// Satu baris hasil RPC `get_conversations()` — dikelompokkan per (item + lawan bicara).
class Conversation {
  final String itemId;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? itemTitle;
  final String? itemThumbnail;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? lastBookingId;
  final String? lastBookingStatus;

  const Conversation({
    required this.itemId,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.itemTitle,
    this.itemThumbnail,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.lastBookingId,
    this.lastBookingStatus,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        itemId: json['item_id'] as String,
        otherUserId: json['other_user_id'] as String,
        otherUserName: json['other_user_name'] as String?,
        otherUserAvatar: json['other_user_avatar'] as String?,
        itemTitle: json['item_title'] as String?,
        itemThumbnail: json['item_thumbnail'] as String?,
        lastMessage: json['last_message'] as String? ?? '',
        lastMessageTime:
            DateTime.parse(json['last_message_time'] as String).toLocal(),
        unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
        lastBookingId: json['last_booking_id'] as String?,
        lastBookingStatus: json['last_booking_status'] as String?,
      );
}