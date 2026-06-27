import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/conversation_model.dart';
import 'chat_provider.dart';

part 'chat_list_provider.g.dart';

/// Daftar percakapan (RPC get_conversations) yang auto-refresh saat ada
/// pesan baru lewat Supabase Realtime.
@riverpod
class ConversationList extends _$ConversationList {
  RealtimeChannel? _channel;

  @override
  Future<List<Conversation>> build() async {
    ref.onDispose(() {
      final ch = _channel;
      if (ch != null) {
        ref.read(supabaseClientProvider).removeChannel(ch);
      }
    });
    _subscribe();
    return ref.read(chatRepositoryProvider).fetchConversations();
  }

  void _subscribe() {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('public:messages:list')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();
  }
}