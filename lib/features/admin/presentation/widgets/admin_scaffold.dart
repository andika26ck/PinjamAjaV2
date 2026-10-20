import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

/// Daftar menu panel admin. `enabled=false` artinya fitur menyusul di fase
/// berikutnya (item drawer tampil tapi belum bisa diklik).
enum AdminSection {
  dashboard('Dashboard', Icons.dashboard_outlined, AppRoutes.admin, true),
  users('Pengguna', Icons.people_outline, AppRoutes.adminUsers, true),
  kyc('Verifikasi KYC', Icons.badge_outlined, AppRoutes.adminKyc, true),
  moderation('Moderasi Barang', Icons.inventory_2_outlined,
      AppRoutes.adminModeration, true),
  reports('Laporan', Icons.flag_outlined, AppRoutes.adminReports, true),
  disputes('Sengketa', Icons.gavel_outlined, AppRoutes.adminDisputes, true),
  // DEPRECATED: digantikan "Pencairan ke Pemilik" (manualPayouts). Disembunyikan
  // dari drawer (deprecated=true) tapi enum-nya dipertahankan agar
  // admin_payouts_screen.dart lama tetap kompilasi. Jangan dipakai lagi.
  payouts('Pencairan (lama)', Icons.account_balance_wallet_outlined,
      AppRoutes.adminPayouts, true, true),
  config('Konfigurasi', Icons.tune, AppRoutes.adminConfig, true),
  manualPayments('Bayar Manual', Icons.receipt_long_outlined,
      AppRoutes.adminManualPayments, true),
  manualPayouts('Pencairan ke Pemilik', Icons.payments_outlined,
      AppRoutes.adminManualPayouts, true),
  manualRefunds('Refund Deposit', Icons.assignment_return_outlined,
      AppRoutes.adminManualRefunds, true);

  const AdminSection(this.label, this.icon, this.route, this.enabled,
      [this.deprecated = false]);
  final String label;
  final IconData icon;
  final String route;
  final bool enabled;

  /// Item lama yang sudah digantikan—disembunyikan dari drawer.
  final bool deprecated;
}

/// Scaffold seragam untuk semua halaman admin: AppBar + Drawer navigasi.
class AdminScaffold extends StatelessWidget {
  final AdminSection current;
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.current,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: _AdminDrawer(current: current),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final AdminSection current;
  const _AdminDrawer({required this.current});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text('Panel Admin',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text('PinjamAja',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final s in AdminSection.values)
                    if (!s.deprecated)
                    ListTile(
                      leading: Icon(
                        s.icon,
                        color: s == current
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      title: Text(s.label),
                      selected: s == current,
                      selectedTileColor:
                          AppColors.primary.withValues(alpha: 0.08),
                      enabled: s.enabled || s == current,
                      trailing: s.enabled
                          ? null
                          : const Text('Segera',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary)),
                      onTap: () {
                        Navigator.pop(context); // tutup drawer
                        if (s != current) context.go(s.route);
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Kembali ke Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}