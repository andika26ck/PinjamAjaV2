import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/chat_repository.dart';
import '../data/models/message_model.dart';
import '../data/supabase_chat_repository.dart';

part 'chat_provider.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(ChatRepositoryRef ref) =>
    SupabaseChatRepository(ref.watch(supabaseClientProvider));

/// State pesan untuk satu booking + subscription realtime.
@riverpod
class ChatController extends _$ChatController {
  RealtimeChannel? _channel;

  @override
  Future<List<Message>> build(String bookingId) async {
    // Bersihkan channel saat provider di-dispose.
    ref.onDispose(() {
      final ch = _channel;
      if (ch != null) {
        ref.read(supabaseClientProvider).removeChannel(ch);
      }
    });

    _subscribe(bookingId);
    final messages =
        await ref.read(chatRepositoryProvider).fetchMessages(bookingId);
    // Tandai pesan masuk sebagai dibaca begitu chat dibuka.
    unawaited(_markRead(bookingId));
    return messages;
  }

  String get _uid =>
      ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';

  // ---- Realtime subscription ----
  void _subscribe(String bookingId) {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('public:messages:$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_id',
            value: bookingId,
          ),
          callback: (payload) {
            final msg = Message.fromJson(payload.newRecord);
            _onIncoming(msg, bookingId);
          },
        )
        .subscribe();
  }

  void _onIncoming(Message msg, String bookingId) {
    final current = state.valueOrNull ?? const <Message>[];
    // Hindari duplikat (pesan kita sendiri sudah masuk via optimistic+insert).
    if (current.any((m) => m.id == msg.id)) return;
    // Ganti placeholder optimistic dengan teks sama bila ada.
    final withoutPending = current
        .where((m) => !(m.pending && m.message == msg.message))
        .toList();
    state = AsyncData([...withoutPending, msg]);
    if (msg.receiverId == _uid) unawaited(_markRead(bookingId));
  }

  // ---- Kirim pesan (optimistic update) ----
  Future<void> sendMessage({
    required String bookingId,
    required String receiverId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final temp = Message(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      senderId: _uid,
      receiverId: receiverId,
      bookingId: bookingId,
      message: trimmed,
      isRead: false,
      timestamp: DateTime.now(),
      pending: true,
    );
    state = AsyncData([...(state.valueOrNull ?? const []), temp]);

    try {
      final saved = await ref.read(chatRepositoryProvider).sendMessage(
            bookingId: bookingId,
            receiverId: receiverId,
            text: trimmed,
          );
      final list = (state.valueOrNull ?? const <Message>[])
          .map((m) => m.id == temp.id ? saved : m)
          .toList();
      // Jika realtime sudah menambah versi server, buang placeholder.
      final dedup = <String, Message>{for (final m in list) m.id: m};
      state = AsyncData(dedup.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
    } catch (e) {
      // Tandai placeholder gagal: hapus dari daftar + lempar error halus.
      final list = (state.valueOrNull ?? const <Message>[])
          .where((m) => m.id != temp.id)
          .toList();
      state = AsyncData(list);
      throw e.toAppException();
    }
  }

  Future<void> _markRead(String bookingId) async {
    try {
      await ref
          .read(chatRepositoryProvider)
          .markAsRead(bookingId: bookingId, myId: _uid);
    } catch (_) {
      // diam saja; bukan kesalahan kritis
    }
  }
}