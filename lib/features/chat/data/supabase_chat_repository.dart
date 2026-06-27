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
  Future<List<Message>> fetchMessages(String bookingId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('booking_id', bookingId)
        .order('timestamp', ascending: true);
    final rows = (data as List).cast<Map<String, dynamic>>();
    return rows.map(Message.fromJson).toList();
  }

  @override
  Future<Message> sendMessage({
    required String bookingId,
    required String receiverId,
    required String text,
  }) async {
    final data = await _client
        .from('messages')
        .insert({
          'sender_id': _uid,
          'receiver_id': receiverId,
          'booking_id': bookingId,
          'message': text,
        })
        .select()
        .single();
    return Message.fromJson(data);
  }

  @override
  Future<void> markAsRead({
    required String bookingId,
    required String myId,
  }) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('booking_id', bookingId)
        .eq('receiver_id', myId)
        .eq('is_read', false);
  }
}