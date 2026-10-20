import 'models/conversation_model.dart';
import 'models/message_model.dart';

abstract class ChatRepository {
  /// Daftar percakapan untuk user yang login (RPC get_conversations).
  Future<List<Conversation>> fetchConversations();

  /// Ambil seluruh pesan satu thread (item + lawan bicara), urut waktu menaik.
  Future<List<Message>> fetchMessages({
    required String itemId,
    required String otherUserId,
  });

  /// Kirim pesan baru, kembalikan baris yang tersimpan.
  /// `bookingId` opsional (diisi bila chat sudah punya konteks booking).
  Future<Message> sendMessage({
    required String itemId,
    required String receiverId,
    String? bookingId,
    required String text,
  });

  /// Tandai semua pesan masuk pada thread ini sebagai dibaca.
  Future<void> markAsRead({
    required String itemId,
    required String otherUserId,
    required String myId,
  });
}