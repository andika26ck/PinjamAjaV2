import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../providers/payment_provider.dart';

class PaymentPendingScreen extends ConsumerWidget {
  final String bookingId;
  const PaymentPendingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Jika webhook akhirnya melunasi, pindah otomatis.
    ref.listen(paymentByBookingProvider(bookingId), (_, next) {
      if (next.valueOrNull?.isPaid == true) {
        context.pushReplacement(AppRoutes.paymentSuccessPath(bookingId));
      }
    });
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/payment_pending.json', height: 160),
              const SizedBox(height: 12),
              const Text('Pembayaran Diproses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Pembayaranmu sedang diverifikasi. Biasanya selesai dalam '
                'beberapa menit. Status akan diperbarui otomatis.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(paymentByBookingProvider(bookingId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Cek Status Pembayaran'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.bookingDetailPath(bookingId)),
                child: const Text('Lihat Detail Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}