import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../providers/payment_provider.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final String bookingId;
  const PaymentSuccessScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment = ref.watch(paymentByBookingProvider(bookingId)).valueOrNull;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/payment_success.json',
                  height: 160, repeat: false),
              const SizedBox(height: 12),
              const Text('Pembayaran Berhasil! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Menunggu konfirmasi dari owner.',
                  style: TextStyle(color: AppColors.textTertiary)),
              const SizedBox(height: 20),
              if (payment != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _row('Total Bayar', payment.formattedTotal),
                        _row('No. Booking',
                            bookingId.substring(0, 8).toUpperCase()),
                        if (payment.paymentMethod != null)
                          _row('Metode', payment.paymentMethod!),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      context.go(AppRoutes.bookingDetailPath(bookingId)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text('Lihat Detail Booking'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.textSecondary)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}