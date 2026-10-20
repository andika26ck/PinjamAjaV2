import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chat_list_provider.dart';

part 'chat_unread_count_provider.g.dart';

/// Total pesan belum dibaca di semua percakapan — untuk badge di tab Chat.
@riverpod
int chatUnreadCount(ChatUnreadCountRef ref) {
  final async = ref.watch(conversationListProvider);
  return async.maybeWhen(
    data: (list) =>
        list.fold<int>(0, (sum, c) => sum + c.unreadCount),
    orElse: () => 0,
  );
}