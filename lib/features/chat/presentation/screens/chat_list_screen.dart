import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../providers/chat_list_provider.dart';
import '../widgets/conversation_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(conversationListProvider.future),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text(
                    e is AppException ? e.message : 'Gagal memuat percakapan.'),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.forum_outlined,
                      size: 56, color: AppColors.textTertiary),
                  SizedBox(height: 12),
                  Center(
                    child: Text('Belum ada percakapan.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final c = items[i];
                return ConversationTile(
                  conversation: c,
                  onTap: () =>
                      context.push(AppRoutes.chatRoomPath(c.bookingId)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}