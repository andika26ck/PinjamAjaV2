import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

class PaymentFailedScreen extends ConsumerWidget {
  final String bookingId;
  final String? reason;
  const PaymentFailedScreen({super.key, required this.bookingId, this.reason});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/payment_failed.json',
                  height: 160, repeat: false),
              const SizedBox(height: 12),
              const Text('Pembayaran Gagal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (reason != null)
                Card(
                  color: AppColors.error.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(reason!, textAlign: TextAlign.center),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      context.pushReplacement(AppRoutes.paymentPath(bookingId)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text('Coba Lagi'),
                ),
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