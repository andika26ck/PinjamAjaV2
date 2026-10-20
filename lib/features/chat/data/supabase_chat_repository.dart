import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_repository.dart';
import 'models/conversation_model.dart';
import 'models/message_model.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;
  SupabaseChatRepository(this._client);

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Sesi tidak ditemukan.');
    return id;
  }

  @override
  Future<List<Conversation>> fetchConversations() async {
    final data = await _client.rpc('get_conversations');
    final rows = (data as List).cast<Map<String, dynamic>>();
    return rows.map(Conversation.fromJson).toList();
  }

  @override
  Future<List<Message>> fetchMessages({
    required String itemId,
    required String otherUserId,
  }) async {
    final me = _uid;
    final data = await _client
        .from('messages')
        .select()
        .eq('item_id', itemId)
        .or('and(sender_id.eq.$me,receiver_id.eq.$otherUserId),'
            'and(sender_id.eq.$otherUserId,receiver_id.eq.$me)')
        .order('timestamp', ascending: true);
    final rows = (data as List).cast<Map<String, dynamic>>();
    return rows.map(Message.fromJson).toList();
  }

  @override
  Future<Message> sendMessage({
    required String itemId,
    required String receiverId,
    String? bookingId,
    required String text,
  }) async {
    final data = await _client
        .from('messages')
        .insert({
          'sender_id': _uid,
          'receiver_id': receiverId,
          'item_id': itemId,
          if (bookingId != null) 'booking_id': bookingId,
          'message': text,
        })
        .select()
        .single();
    return Message.fromJson(data);
  }

  @override
  Future<void> markAsRead({
    required String itemId,
    required String otherUserId,
    required String myId,
  }) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('item_id', itemId)
        .eq('receiver_id', myId)
        .eq('sender_id', otherUserId)
        .eq('is_read', false);
  }
}