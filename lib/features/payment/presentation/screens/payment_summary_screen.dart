import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/payment_model.dart';
import '../../providers/payment_provider.dart';

class PaymentSummaryScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const PaymentSummaryScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PaymentSummaryScreen> createState() =>
      _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends ConsumerState<PaymentSummaryScreen> {
  bool _loading = false;

  Future<void> _payNow() async {
    setState(() => _loading = true);
    try {
      final req = await ref.read(paymentRepositoryProvider).createPayment(widget.bookingId);
      if (!mounted) return;
      context.push(
        AppRoutes.paymentWebviewPath(widget.bookingId),
        extra: req.snapToken,
      );
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memulai pembayaran.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigate bila sudah lunas (webhook lebih cepat dari redirect).
    ref.listen(paymentByBookingProvider(widget.bookingId), (_, next) {
      final p = next.valueOrNull;
      if (p != null && p.isPaid && mounted) {
        context.pushReplacement(AppRoutes.paymentSuccessPath(widget.bookingId));
      }
    });

    final paymentAsync = ref.watch(paymentByBookingProvider(widget.bookingId));
    final existing = paymentAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (existing != null) ...[
            _PriceRow('Harga sewa', existing.formattedRentalFee),
            _PriceRow('Deposit (dikembalikan)', existing.formattedDeposit),
            _PriceRow('Biaya layanan (5%)', existing.formattedPlatformFee),
            const Divider(height: 24),
            _PriceRow('TOTAL', existing.formattedTotal, bold: true),
            if (existing.expiredAt != null) ...[
              const SizedBox(height: 16),
              _CountdownCard(expiredAt: existing.expiredAt!),
            ],
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tekan tombol di bawah untuk melihat rincian & membayar.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.surfaceVariant,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Deposit akan dikembalikan setelah barang kembali dalam '
                      'kondisi baik. Proses refund 1-3 hari kerja.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loading ? null : _payNow,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: _loading
                ? const SizedBox(
                    height: 22, width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text(existing != null
                    ? 'Bayar ${existing.formattedTotal}'
                    : 'Pilih Metode & Bayar'),
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final DateTime expiredAt;
  const _CountdownCard({required this.expiredAt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Selesaikan pembayaran sebelum '
                '${Formatters.dateTime(expiredAt)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}