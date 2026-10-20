import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/user_profile.dart';
import '../../../payment/providers/manual_payment_provider.dart';
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
      appBar: AppBar(
        title: const Text('Detail Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            tooltip: 'Beranda',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
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
    final awaitingPayment = b.status == 'awaiting_payment';
    final manualPayment =
        ref.watch(manualPaymentByBookingProvider(bookingId)).valueOrNull;
    final awaitingVerification = manualPayment?.awaitingVerification ?? false;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Breadcrumb(isOwner: bundle.isOwner),
              const SizedBox(height: 16),
              if (cancelled)
                _banner(b.cancellationReason, refundStatus: b.refundStatus)
              else if (awaitingPayment)
                (awaitingVerification
                    ? const _ManualVerificationBanner()
                    : _PaymentDueBanner(expiresAt: b.expiresAt))
              else ...[
                _Timeline(current: _stepIndex(b.status)),
                if (b.status == 'pending' &&
                    b.paymentStatus == 'paid' &&
                    !bundle.isOwner) ...[
                  const SizedBox(height: 16),
                  _ConfirmDeadlineBanner(deadline: b.confirmationDeadline),
                ],
              ],
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
              if (b.startedAt != null)
                _kv('Mulai disewa', _formatDateTimeId(b.startedAt)),
              if (b.returnedAt != null)
                _kv('Dikembalikan', _formatDateTimeId(b.returnedAt)),
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
              if (b.status == 'completed') ...[
                const SizedBox(height: 20),
                _LateFeeSection(booking: b),
              ],
              if (b.notes != null && b.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _sectionTitle('Catatan'),
                Text(b.notes!,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.chatRoomByBookingPath(b.id)),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat terkait booking ini'),
              ),
              if (b.status == 'active' || b.status == 'completed') ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error),
                  onPressed: () => context.push(
                    AppRoutes.disputeSubmissionPath(b.id),
                    extra: bundle.isOwner ? b.renterId : b.ownerId,
                  ),
                  icon: const Icon(Icons.gavel_outlined),
                  label: const Text('Ajukan Sengketa'),
                ),
              ],
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
    final manualPayment = ref
        .watch(manualPaymentByBookingProvider(bundle.booking.id))
        .valueOrNull;
    final awaitingVerification = manualPayment?.awaitingVerification ?? false;

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
            onPressed: busy ? null : () => notifier.markReturned(b),
            child: const Text('Tandai Dikembalikan'),
          ),
        ));
      }
    } else {
      // Renter
      if (b.status == 'awaiting_payment') {
        children.addAll([
          Expanded(
            child: OutlinedButton(
              style:
                  OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: busy ? null : () => _cancelFlow(context, ref),
              child: const Text('Batalkan'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: busy ? null : () => _resumePayment(context),
              icon: Icon(
                  awaitingVerification ? Icons.hourglass_top : Icons.payment,
                  size: 18),
              label: Text(awaitingVerification
                  ? 'Lihat Status Pembayaran'
                  : 'Bayar Sekarang'),
            ),
          ),
        ]);
      } else if (b.status == 'pending') {
        children.add(Expanded(
          child: OutlinedButton(
            style:
                OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: busy ? null : () => _cancelFlow(context, ref),
            child: const Text('Batalkan Booking'),
          ),
        ));
      } else if (b.status == 'completed') {
        if (b.lateFeeStatus == 'unpaid') {
          children.add(Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error),
              onPressed: busy ? null : () => _payLateFeeFlow(context, ref),
              icon: const Icon(Icons.payment, size: 18),
              label: Text(
                  'Bayar Denda ${Formatters.rupiah(_outstanding(b))}'),
            ),
          ));
        } else if (!bundle.hasReview) {
          children.add(Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : () => _reviewFlow(context, ref),
              child: const Text('Beri Ulasan'),
            ),
          ));
        }
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

  void _resumePayment(BuildContext context) {
    // Bayar Manual: lanjut bayar lewat route (transfer/QRIS + upload bukti).
    context.push(AppRoutes.bookingManualPaymentPath(bundle.booking.id));
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
    await ref.read(bookingControllerProvider.notifier).cancelBooking(
          bundle.booking.id,
          reason: 'Dibatalkan oleh penyewa',
          refund: bundle.booking.paymentStatus == 'paid',
        );
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
    await ref.read(bookingControllerProvider.notifier).rejectBooking(
          bundle.booking.id,
          reason: reason,
          refund: bundle.booking.paymentStatus == 'paid',
        );
  }

  Future<void> _reviewFlow(BuildContext context, WidgetRef ref) async {
    var rating = 5;
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
                    onPressed: () => setLocal(() => rating = i + 1),
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

  int _outstanding(Booking b) {
    final used = b.depositAmount - (b.depositRefund ?? b.depositAmount);
    final o = b.lateFee - used;
    return o < 0 ? 0 : o;
  }

  Future<void> _payLateFeeFlow(BuildContext context, WidgetRef ref) async {
    final b = bundle.booking;
    final used = b.depositAmount - (b.depositRefund ?? b.depositAmount);
    final amount = _outstanding(b);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bayar Denda Keterlambatan'),
        content: Text(
          'Barang telat dikembalikan ${b.lateDays} hari.\n'
          'Total denda: ${Formatters.rupiah(b.lateFee)}.'
          '${used > 0 ? '\nSudah dipotong deposit: ${Formatters.rupiah(used)}.' : ''}'
          '\nSisa yang harus dibayar: ${Formatters.rupiah(amount)}.\n\n'
          'Ini pembayaran simulasi untuk demo.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Nanti')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Bayar ${Formatters.rupiah(amount)}'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success =
        await ref.read(bookingControllerProvider.notifier).payLateFee(b.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denda lunas. Terima kasih!')),
      );
    }
  }

  // ---- Bagian UI kecil ----
  Widget _banner(String? reason, {String refundStatus = 'none'}) => Container(
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
                  if (refundStatus == 'refunded') ...[
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 14, color: AppColors.success),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text('Dana pembayaran sudah dikembalikan',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ),
                      ],
                    ),
                  ],
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

class _Breadcrumb extends StatelessWidget {
  final bool isOwner;
  const _Breadcrumb({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
        fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600);
    Widget sep() => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right,
              size: 14, color: AppColors.textTertiary),
        );
    return Row(
      children: [
        InkWell(
          onTap: () => context.go(AppRoutes.home),
          child: const Text('Beranda', style: linkStyle),
        ),
        sep(),
        InkWell(
          onTap: () => context.go(
              isOwner ? AppRoutes.ownerBookings : AppRoutes.myBookings),
          child: Text(isOwner ? 'Booking Masuk' : 'Booking Saya',
              style: linkStyle),
        ),
        sep(),
        const Flexible(
          child: Text('Detail',
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ),
      ],
    );
  }
}

/// Banner penyewa: bukti bayar manual sudah dikirim, menunggu verifikasi admin.
class _ManualVerificationBanner extends StatelessWidget {
  const _ManualVerificationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menunggu verifikasi admin',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 2),
                const Text(
                    'Bukti pembayaranmu sudah dikirim. Admin akan mengecek dan '
                    'mengonfirmasi. Tekan "Lihat Status Pembayaran" untuk '
                    'memantau prosesnya.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDueBanner extends StatelessWidget {
  final DateTime? expiresAt;
  const _PaymentDueBanner({this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final due = expiresAt?.toLocal();
    final dueText = due == null
        ? 'dalam 24 jam'
        : 'sebelum ${due.day}/${due.month}/${due.year} '
            '${due.hour.toString().padLeft(2, '0')}:'
            '${due.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menunggu pembayaran',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning)),
                Text(
                    'Selesaikan pembayaran $dueText, atau booking otomatis '
                    'dibatalkan.',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner penyewa: menunggu konfirmasi pemilik + tenggat auto-refund (escrow).
class _ConfirmDeadlineBanner extends StatelessWidget {
  final DateTime? deadline;
  const _ConfirmDeadlineBanner({this.deadline});

  @override
  Widget build(BuildContext context) {
    final due = deadline?.toLocal();
    final dueText = due == null
        ? 'dalam 24 jam'
        : 'sebelum ${due.day}/${due.month}/${due.year} '
            '${due.hour.toString().padLeft(2, '0')}:'
            '${due.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menunggu konfirmasi pemilik',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 2),
                Text(
                    'Pembayaranmu aman ditahan PinjamAja. Pemilik harus '
                    'mengonfirmasi $dueText. Jika tidak, booking otomatis '
                    'dibatalkan dan dana dikembalikan penuh.',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

/// Format tanggal + jam, mis. "3 Jul 2026, 14:05" (waktu lokal).
String _formatDateTimeId(DateTime? dt) {
  if (dt == null) return '-';
  final d = dt.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]} ${d.year}, $hh:$mm';
}

/// Ringkasan denda keterlambatan + rincian deposit.
class _LateFeeSection extends StatelessWidget {
  final Booking booking;
  const _LateFeeSection({required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final used = b.depositAmount - (b.depositRefund ?? b.depositAmount);
    final refund = b.depositRefund ?? b.depositAmount;
    final rawOut = b.lateFee - used;
    final outstanding = rawOut < 0 ? 0 : rawOut;
    final onTime = b.lateFee == 0;

    final color = onTime ? AppColors.success : AppColors.error;
    final title =
        onTime ? 'Dikembalikan tepat waktu' : 'Telat ${b.lateDays} hari';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                onTime
                    ? Icons.verified_outlined
                    : Icons.warning_amber_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!onTime)
            _row('Denda keterlambatan', Formatters.rupiah(b.lateFee)),
          _row('Deposit', Formatters.rupiah(b.depositAmount)),
          if (used > 0)
            _row('Deposit dipakai untuk denda',
                '- ${Formatters.rupiah(used)}'),
          _row('Deposit dikembalikan', Formatters.rupiah(refund),
              strong: true, color: AppColors.success),
          if (outstanding > 0) ...[
            const Divider(height: 18),
            _row(
              b.lateFeeStatus == 'paid'
                  ? 'Sisa denda (sudah LUNAS)'
                  : 'Sisa denda harus dibayar',
              Formatters.rupiah(outstanding),
              strong: true,
              color: b.lateFeeStatus == 'paid'
                  ? AppColors.success
                  : AppColors.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v, {bool strong = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(k,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
            const SizedBox(width: 12),
            Text(v,
                style: TextStyle(
                    fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                    color: color)),
          ],
        ),
      );
}