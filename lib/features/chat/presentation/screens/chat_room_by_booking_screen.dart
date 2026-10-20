import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../providers/chat_context_provider.dart';
import 'chat_screen.dart';

/// Pembungkus untuk entry-point lama berbasis bookingId (notifikasi/deep link).
/// Mengubah bookingId -> (itemId, otherUserId) lalu menampilkan ChatScreen.
class ChatRoomByBookingScreen extends ConsumerWidget {
  final String bookingId;
  const ChatRoomByBookingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chatTargetFromBookingProvider(bookingId));
    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Text(e is AppException ? e.message : 'Gagal membuka chat.'),
        ),
      ),
      data: (t) =>
          ChatScreen(itemId: t.itemId, otherUserId: t.otherUserId),
    );
  }
}