import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../data/models/user_profile.dart';
import '../../providers/auth_notifier.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _submitting;

  Future<void> _select(UserRole role) async {
    setState(() => _submitting = role);
    final ok = await ref.read(authControllerProvider.notifier).updateRole(role);
    if (!mounted) return;
    if (!ok) {
      setState(() => _submitting = null); // error ditangani lewat listener
    }
    // Sukses → router otomatis mengarahkan ke /home.
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      next.whenOrNull(error: (e, _) {
        final msg = e is AppException ? e.message : 'Terjadi kesalahan.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Kamu ingin?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih peran utamamu. Kamu tetap bisa beralih kapan saja.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _RoleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Saya ingin Menyewa',
                description:
                    'Cari & sewa barang yang kamu butuhkan dari orang di sekitarmu.',
                loading: _submitting == UserRole.renter,
                disabled: _submitting != null,
                onTap: () => _select(UserRole.renter),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.storefront_outlined,
                title: 'Saya ingin Menyewakan',
                description:
                    'Daftarkan barangmu dan hasilkan uang dari barang menganggur.',
                loading: _submitting == UserRole.owner,
                disabled: _submitting != null,
                onTap: () => _select(UserRole.owner),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}