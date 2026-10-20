import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_notifier.dart';

/// Pusat pengaturan keamanan akun:
/// - Status verifikasi email + kirim ulang email verifikasi
/// - Ganti kata sandi
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _checking = false;

  Future<void> _resendVerification(String email) async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .resendEmailVerification(email);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Email verifikasi telah dikirim ulang. Cek kotak masuk kamu.'),
        ),
      );
    }
  }

  /// Segarkan sesi agar status verifikasi terbaru ikut terbaca
  /// (mis. setelah user verifikasi lewat email).
  Future<void> _refreshStatus() async {
    setState(() => _checking = true);
    try {
      await ref.read(supabaseClientProvider).auth.refreshSession();
    } catch (_) {
      // Abaikan; status akan dimuat ulang saat token berikutnya.
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        final msg = e is AppException ? e.message : 'Terjadi kesalahan.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      });
    });

    final user = ref.watch(supabaseClientProvider).auth.currentUser;
    final email = (user?.email?.isNotEmpty ?? false) ? user!.email! : '-';
    final verified = user?.emailConfirmedAt != null;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Kartu verifikasi email =====
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        verified
                            ? Icons.verified_outlined
                            : Icons.gpp_maybe_outlined,
                        color: verified
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Verifikasi Email',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (verified
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          verified ? 'Terverifikasi' : 'Belum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: verified
                                ? AppColors.success
                                : AppColors.secondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    verified
                        ? 'Email kamu sudah terverifikasi.'
                        : 'Email kamu belum terverifikasi. Kirim ulang tautan verifikasi lalu cek kotak masuk/spam.',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (!verified) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (isLoading || email == '-')
                                ? null
                                : () => _resendVerification(email),
                            icon: const Icon(Icons.mark_email_read_outlined,
                                size: 18),
                            label: const Text('Kirim Ulang'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _checking ? null : _refreshStatus,
                          child: _checking
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Perbarui'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== Ganti kata sandi =====
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.password_outlined,
                  color: AppColors.primary),
              title: const Text('Ganti Kata Sandi'),
              subtitle: const Text('Perbarui kata sandi akunmu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.changePassword),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Lupa kata sandi? Kamu bisa meresetnya lewat tautan "Lupa kata sandi?" di halaman masuk.',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}