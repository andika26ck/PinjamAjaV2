import 'models/conversation_model.dart';
import 'models/message_model.dart';

abstract class ChatRepository {
  /// Daftar percakapan untuk user yang login (RPC get_conversations).
  Future<List<Conversation>> fetchConversations();

  /// Ambil seluruh pesan satu booking, urut waktu menaik.
  Future<List<Message>> fetchMessages(String bookingId);

  /// Kirim pesan baru, kembalikan baris yang tersimpan.
  Future<Message> sendMessage({
    required String bookingId,
    required String receiverId,
    required String text,
  });

  /// Tandai semua pesan masuk pada booking ini sebagai dibaca.
  Future<void> markAsRead({required String bookingId, required String myId});
}