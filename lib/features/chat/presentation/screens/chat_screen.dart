import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../booking/presentation/widgets/booking_card.dart'
    show bookingStatusLabel, bookingStatusColor;
import '../../providers/chat_context_provider.dart';
import '../../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String otherUserId;
  const ChatScreen({
    super.key,
    required this.itemId,
    required this.otherUserId,
  });

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

  Future<void> _send(String receiverId, String? bookingId) async {
    final text = _inputC.text;
    if (text.trim().isEmpty) return;
    _inputC.clear();
    try {
      await ref
          .read(chatControllerProvider(widget.itemId, widget.otherUserId)
              .notifier)
          .sendMessage(
            itemId: widget.itemId,
            receiverId: receiverId,
            bookingId: bookingId,
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
    final ctxAsync =
        ref.watch(chatContextProvider(widget.itemId, widget.otherUserId));
    final msgsAsync =
        ref.watch(chatControllerProvider(widget.itemId, widget.otherUserId));

    // Auto-scroll setiap ada pesan baru.
    ref.listen(chatControllerProvider(widget.itemId, widget.otherUserId),
        (_, __) {
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
          // ---- Context card: info item + status booking + CTA sewa ----
          ctxAsync.maybeWhen(
            data: (c) {
              final isOwner = c.item?.ownerId == c.myId;
              final hasActiveBooking = c.booking != null &&
                  c.booking!.status != 'cancelled' &&
                  c.booking!.status != 'completed';
              // Tampilkan CTA hanya untuk penyewa (bukan pemilik barang)
              // dan saat belum ada booking yang masih berjalan.
              final canRent =
                  !isOwner && c.item != null && !hasActiveBooking;
              return Column(
                children: [
                  _ContextCard(
                    itemTitle: c.item?.title,
                    itemThumb: c.item?.thumbnailUrl,
                    status: c.booking?.status,
                  ),
                  if (canRent)
                    _RentCtaButton(
                      onTap: () => context.push(
                        AppRoutes.bookingPath(c.itemId),
                        extra: c.item,
                      ),
                    ),
                ],
              );
            },
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
          _inputBar(
            ctxAsync.valueOrNull?.otherUserId ?? widget.otherUserId,
            ctxAsync.valueOrNull?.booking?.id,
          ),
        ],
      ),
    );
  }

  Widget _inputBar(String receiverId, String? bookingId) {
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
                onSubmitted: (_) => _send(receiverId, bookingId),
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
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _send(receiverId, bookingId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol ajakan menyewa di dalam ruang chat (khusus penyewa).
class _RentCtaButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RentCtaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.calendar_month_outlined, size: 18),
          label: const Text('Ajukan Sewa'),
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final String? itemTitle;
  final String? itemThumb;
  final String? status; // null bila belum ada booking
  const _ContextCard({this.itemTitle, this.itemThumb, this.status});

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    final hasBooking = status != null;
    final color =
        hasBooking ? bookingStatusColor(status) : AppColors.textTertiary;
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
              hasBooking ? bookingStatusLabel(status) : 'Belum ada booking',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}