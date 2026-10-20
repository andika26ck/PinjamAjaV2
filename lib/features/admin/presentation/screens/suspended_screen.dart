import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../auth/providers/auth_provider.dart';

class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appAuthProvider).profile;
    final reason = profile?.suspendedReason;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.block, size: 72, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Akun Dibekukan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Akun kamu sedang dibekukan oleh admin, jadi untuk sementara tidak bisa mengakses aplikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              if (reason != null && reason.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alasan:',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error)),
                      const SizedBox(height: 4),
                      Text(reason,
                          style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Text(
                'Kalau menurutmu ini keliru, hubungi tim PinjamAja di support@pinjamaja.app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}