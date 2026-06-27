import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/payment_model.dart';
import '../../providers/payment_provider.dart';

class RefundStatusCard extends ConsumerWidget {
  final String bookingId;
  final bool isOwner;
  const RefundStatusCard({
    super.key,
    required this.bookingId,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment = ref.watch(paymentByBookingProvider(bookingId)).valueOrNull;
    if (payment == null || payment.depositAmount <= 0) {
      return const SizedBox.shrink();
    }

    if (payment.isRefunded) {
      return _banner(
        AppColors.success,
        Icons.check_circle,
        'Deposit ${payment.formattedDeposit} sudah dikembalikan',
      );
    }
    if (payment.status == PaymentStatusType.refundPending) {
      return _banner(
        AppColors.secondary,
        Icons.hourglass_top,
        'Refund deposit sedang diproses',
      );
    }
    if (payment.isPaid) {
      // Owner bisa memicu refund; penyewa hanya melihat info.
      if (isOwner) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deposit ${payment.formattedDeposit} ditahan',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmRefund(context, ref),
                    child: const Text('Konfirmasi Barang Kembali & Refund'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return _banner(
        AppColors.secondary,
        Icons.info_outline,
        'Deposit ${payment.formattedDeposit} akan dikembalikan setelah barang dicek owner',
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _confirmRefund(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi pengembalian'),
        content: const Text(
            'Barang sudah diterima kembali dalam kondisi baik? Deposit akan dikembalikan ke penyewa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Refund')),
        ],
      ),
    );
    if (ok != true) return;
    final success = await ref
        .read(refundControllerProvider.notifier)
        .requestRefund(bookingId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Refund deposit diproses' : 'Gagal memproses refund'),
      ));
    }
  }

  Widget _banner(Color color, IconData icon, String text) => Card(
        color: color.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
}