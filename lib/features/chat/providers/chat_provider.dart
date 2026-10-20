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

/// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
@riverpod
class ChatController extends _$ChatController {
  RealtimeChannel? _channel;

  @override
  Future<List<Message>> build(String itemId, String otherUserId) async {
    // Bersihkan channel saat provider di-dispose.
    ref.onDispose(() {
      final ch = _channel;
      if (ch != null) {
        ref.read(supabaseClientProvider).removeChannel(ch);
      }
    });

    _subscribe(itemId, otherUserId);
    final messages = await ref
        .read(chatRepositoryProvider)
        .fetchMessages(itemId: itemId, otherUserId: otherUserId);
    // Tandai pesan masuk sebagai dibaca begitu chat dibuka.
    unawaited(_markRead(itemId, otherUserId));
    return messages;
  }

  String get _uid =>
      ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';

  bool _belongsToPair(Message m, String otherUserId) {
    final me = _uid;
    return (m.senderId == me && m.receiverId == otherUserId) ||
        (m.senderId == otherUserId && m.receiverId == me);
  }

  // ---- Realtime subscription ----
  void _subscribe(String itemId, String otherUserId) {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('public:messages:item:$itemId:$otherUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'item_id',
            value: itemId,
          ),
          callback: (payload) {
            final msg = Message.fromJson(payload.newRecord);
            // Channel hanya difilter per item_id; saring lagi per pasangan.
            if (!_belongsToPair(msg, otherUserId)) return;
            _onIncoming(msg, itemId, otherUserId);
          },
        )
        .subscribe();
  }

  void _onIncoming(Message msg, String itemId, String otherUserId) {
    final current = state.valueOrNull ?? const <Message>[];
    // Hindari duplikat (pesan kita sendiri sudah masuk via optimistic+insert).
    if (current.any((m) => m.id == msg.id)) return;
    // Ganti placeholder optimistic dengan teks sama bila ada.
    final withoutPending = current
        .where((m) => !(m.pending && m.message == msg.message))
        .toList();
    state = AsyncData([...withoutPending, msg]);
    if (msg.receiverId == _uid) unawaited(_markRead(itemId, otherUserId));
  }

  // ---- Kirim pesan (optimistic update) ----
  Future<void> sendMessage({
    required String itemId,
    required String receiverId,
    String? bookingId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final temp = Message(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      senderId: _uid,
      receiverId: receiverId,
      itemId: itemId,
      bookingId: bookingId,
      message: trimmed,
      isRead: false,
      timestamp: DateTime.now(),
      pending: true,
    );
    state = AsyncData([...(state.valueOrNull ?? const []), temp]);

    try {
      final saved = await ref.read(chatRepositoryProvider).sendMessage(
            itemId: itemId,
            receiverId: receiverId,
            bookingId: bookingId,
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

  Future<void> _markRead(String itemId, String otherUserId) async {
    try {
      await ref.read(chatRepositoryProvider).markAsRead(
            itemId: itemId,
            otherUserId: otherUserId,
            myId: _uid,
          );
    } catch (_) {
      // diam saja; bukan kesalahan kritis
    }
  }
}