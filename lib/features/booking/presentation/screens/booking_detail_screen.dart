import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/user_profile.dart';
import '../../providers/booking_detail_provider.dart';
import '../../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingDetailProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Booking')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
              e is AppException ? e.message : 'Gagal memuat booking.'),
        ),
        data: (d) => _DetailBody(bundle: d, bookingId: bookingId),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final BookingDetailBundle bundle;
  final String bookingId;
  const _DetailBody({required this.bundle, required this.bookingId});

  int _stepIndex(String s) => switch (s) {
        'pending' => 0,
        'confirmed' => 1,
        'active' => 2,
        'completed' => 3,
        _ => -1,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = bundle.booking;
    final busy = ref.watch(bookingControllerProvider).isLoading;

    ref.listen<AsyncValue<void>>(bookingControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(e is AppException ? e.message : 'Terjadi kesalahan.'),
          backgroundColor: AppColors.error,
        ));
      });
    });

    final cancelled = b.status == 'cancelled';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (cancelled)
                _banner(b.cancellationReason)
              else
                _Timeline(current: _stepIndex(b.status)),
              const SizedBox(height: 20),
              if (bundle.item != null) ...[
                _sectionTitle('Barang'),
                _itemRow(context),
                const SizedBox(height: 20),
              ],
              _sectionTitle('Pihak'),
              _partyRow('Penyewa', bundle.renter),
              _partyRow('Pemilik', bundle.owner),
              const SizedBox(height: 20),
              _sectionTitle('Periode Sewa'),
              _kv('Mulai', formatShortDate(b.startDate)),
              _kv('Selesai', formatShortDate(b.endDate)),
              _kv('Total hari', '${b.totalDay} hari'),
              const SizedBox(height: 20),
              _sectionTitle('Rincian Biaya'),
              _kv('Harga sewa',
                  '${Formatters.rupiah(b.pricePerDay)} × ${b.totalDay} hari'),
              _kv('Subtotal',
                  Formatters.rupiah(b.pricePerDay * b.totalDay)),
              _kv('Deposit', Formatters.rupiah(b.depositAmount)),
              _kv('Biaya layanan', Formatters.rupiah(b.platformFee)),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  Text(Formatters.rupiah(b.totalPrice),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 16)),
                ],
              ),
              _kv('Status pembayaran',
                  b.paymentStatus == 'paid' ? 'Lunas' : 'Belum dibayar'),
              if (b.notes != null && b.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _sectionTitle('Catatan'),
                Text(b.notes!,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.chatRoomPath(b.id)),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat terkait booking ini'),
              ),
            ],
          ),
        ),
        _actionBar(context, ref, busy),
      ],
    );
  }

  // ---- Aksi sesuai status & role ----
  Widget _actionBar(BuildContext context, WidgetRef ref, bool busy) {
    final b = bundle.booking;
    final notifier = ref.read(bookingControllerProvider.notifier);
    final children = <Widget>[];

    if (bundle.isOwner) {
      if (b.status == 'pending') {
        children.addAll([
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error),
              onPressed: busy ? null : () => _rejectFlow(context, ref),
              child: const Text('Tolak'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : () => notifier.confirmBooking(b.id),
              child: const Text('Terima'),
            ),
          ),
        ]);
      } else if (b.status == 'confirmed') {
        children.add(Expanded(
          child: ElevatedButton(
            onPressed: busy ? null : () => notifier.startRental(b.id),
            child: const Text('Mulai Sewa'),
          ),
        ));
      } else if (b.status == 'active') {
        children.add(Expanded(
          child: ElevatedButton(
            onPressed: busy ? null : () => notifier.markReturned(b.id),
            child: const Text('Tandai Dikembalikan'),
          ),
        ));
      }
    } else {
      // Renter
      if (b.status == 'pending') {
        children.add(Expanded(
          child: OutlinedButton(
            style:
                OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: busy ? null : () => _cancelFlow(context, ref),
            child: const Text('Batalkan Booking'),
          ),
        ));
      } else if (b.status == 'completed' && !bundle.hasReview) {
        children.add(Expanded(
          child: ElevatedButton(
            onPressed: busy ? null : () => _reviewFlow(context, ref),
            child: const Text('Beri Ulasan'),
          ),
        ));
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: children),
      ),
    );
  }

  Future<void> _cancelFlow(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        content: const Text('Booking yang dibatalkan tidak bisa dipulihkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Tidak')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(bookingControllerProvider.notifier)
        .cancelBooking(bundle.booking.id, reason: 'Dibatalkan oleh penyewa');
  }

  Future<void> _rejectFlow(BuildContext context, WidgetRef ref) async {
    final c = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Booking'),
        content: TextField(
          controller: c,
          maxLines: 2,
          decoration:
              const InputDecoration(hintText: 'Alasan penolakan (opsional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(
                ctx,
                c.text.trim().isEmpty
                    ? 'Ditolak oleh pemilik'
                    : c.text.trim()),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    await ref
        .read(bookingControllerProvider.notifier)
        .rejectBooking(bundle.booking.id, reason: reason);
  }

  Future<void> _reviewFlow(BuildContext context, WidgetRef ref) async {
    var rating = 5.0;
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Beri Ulasan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setLocal(() => rating = i + 1.0),
                    icon: Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: c,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Tulis ulasan (opsional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Kirim')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final success =
        await ref.read(bookingControllerProvider.notifier).submitReview(
              bookingId: bundle.booking.id,
              itemId: bundle.booking.itemId,
              rating: rating,
              comment: c.text,
            );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan terkirim. Terima kasih!')),
      );
    }
  }

  // ---- Bagian UI kecil ----
  Widget _banner(String? reason) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.statusCancelled.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined,
                color: AppColors.statusCancelled),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking dibatalkan',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusCancelled)),
                  if (reason != null && reason.isNotEmpty)
                    Text(reason,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      );

  Widget _itemRow(BuildContext context) {
    final item = bundle.item!;
    return InkWell(
      onTap: () => context.push(AppRoutes.itemDetailPath(item.id)),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.thumbnailUrl != null
                  ? Image.network(item.thumbnailUrl!, fit: BoxFit.cover)
                  : const ColoredBox(color: AppColors.surfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _partyRow(String role, UserProfile? p) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage:
                  (p?.avatarUrl != null) ? NetworkImage(p!.avatarUrl!) : null,
              child: (p?.avatarUrl == null)
                  ? const Icon(Icons.person,
                      size: 18, color: AppColors.textTertiary)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                  Text(p?.name ?? 'Pengguna',
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.textSecondary)),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

class _Timeline extends StatelessWidget {
  final int current; // 0..3
  const _Timeline({required this.current});
  static const _steps = ['Menunggu', 'Dikonfirmasi', 'Aktif', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final done = (i ~/ 2) < current;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.only(top: 12),
              color: done ? AppColors.primary : AppColors.border,
            ),
          );
        }
        final idx = i ~/ 2;
        final reached = idx <= current;
        return SizedBox(
          width: 62,
          child: Column(
            children: [
              Container(
                height: 26,
                width: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: reached
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reached ? Icons.check : Icons.circle_outlined,
                  size: 15,
                  color: reached ? Colors.white : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              Text(_steps[idx],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: reached
                          ? AppColors.textPrimary
                          : AppColors.textTertiary)),
            ],
          ),
        );
      }),
    );
  }
}