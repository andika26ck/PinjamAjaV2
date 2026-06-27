import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../booking/presentation/widgets/booking_card.dart'
    show bookingStatusLabel, bookingStatusColor;
import '../../providers/chat_context_provider.dart';
import '../../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const ChatScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputC = TextEditingController();
  final _scrollC = ScrollController();

  @override
  void dispose() {
    _inputC.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollC.hasClients) return;
      _scrollC.animateTo(
        _scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String receiverId) async {
    final text = _inputC.text;
    if (text.trim().isEmpty) return;
    _inputC.clear();
    try {
      await ref.read(chatControllerProvider(widget.bookingId).notifier).sendMessage(
            bookingId: widget.bookingId,
            receiverId: receiverId,
            text: text,
          );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e is AppException ? e.message : 'Gagal mengirim pesan.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctxAsync = ref.watch(chatContextProvider(widget.bookingId));
    final msgsAsync = ref.watch(chatControllerProvider(widget.bookingId));

    // Auto-scroll setiap ada pesan baru.
    ref.listen(chatControllerProvider(widget.bookingId), (_, __) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: ctxAsync.maybeWhen(
          data: (c) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: c.otherUser?.avatarUrl != null
                    ? NetworkImage(c.otherUser!.avatarUrl!)
                    : null,
                child: c.otherUser?.avatarUrl == null
                    ? const Icon(Icons.person,
                        size: 18, color: AppColors.textTertiary)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.otherUser?.name ?? 'Pengguna',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          orElse: () => const Text('Chat'),
        ),
      ),
      body: Column(
        children: [
          // ---- Context card: info item + status booking ----
          ctxAsync.maybeWhen(
            data: (c) => _ContextCard(
              itemTitle: c.item?.title,
              itemThumb: c.item?.thumbnailUrl,
              status: c.booking.status,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: msgsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                    e is AppException ? e.message : 'Gagal memuat pesan.'),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pesan. Sapa dulu, yuk!',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                final myId = ctxAsync.valueOrNull?.myId;
                return ListView.builder(
                  controller: _scrollC,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    return MessageBubble(
                      message: m,
                      isMine: m.senderId == myId,
                    );
                  },
                );
              },
            ),
          ),
          _inputBar(ctxAsync.valueOrNull?.otherUserId),
        ],
      ),
    );
  }

  Widget _inputBar(String? receiverId) {
    final canSend = receiverId != null;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputC,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted:
                    canSend ? (_) => _send(receiverId) : null,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  canSend ? AppColors.primary : AppColors.textTertiary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: canSend ? () => _send(receiverId) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final String? itemTitle;
  final String? itemThumb;
  final String status;
  const _ContextCard({this.itemTitle, this.itemThumb, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = bookingStatusColor(status);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: itemThumb != null
                  ? Image.network(itemThumb!, fit: BoxFit.cover)
                  : const ColoredBox(
                      color: AppColors.surfaceVariant,
                      child: Icon(Icons.inventory_2_outlined,
                          size: 18, color: AppColors.textTertiary),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              itemTitle ?? 'Barang',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              bookingStatusLabel(status),
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}