import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/admin_stats.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminScaffold(
      current: AdminSection.dashboard,
      title: 'Dashboard Admin',
      actions: [
        IconButton(
          tooltip: 'Muat ulang',
          onPressed: () => ref.invalidate(adminDashboardStatsProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(adminDashboardStatsProvider.future);
        },
        child: statsAsync.when(
          loading: () => const _DashboardLoading(),
          error: (e, _) => _DashboardError(
            onRetry: () => ref.invalidate(adminDashboardStatsProvider),
          ),
          data: (stats) => _DashboardBody(
            name: ref.watch(appAuthProvider).profile?.name ?? 'Admin',
            stats: stats,
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final String name;
  final AdminDashboardStats stats;
  const _DashboardBody({required this.name, required this.stats});

  @override
  Widget build(BuildContext context) {
    final attention = <Widget>[
      if (stats.kycPending > 0)
        _AttentionCard(
            icon: Icons.badge_outlined,
            label: 'KYC menunggu',
            value: '${stats.kycPending}'),
      if (stats.openReports > 0)
        _AttentionCard(
            icon: Icons.flag_outlined,
            label: 'Laporan terbuka',
            value: '${stats.openReports}'),
      if (stats.openDisputes > 0)
        _AttentionCard(
            icon: Icons.gavel_outlined,
            label: 'Sengketa terbuka',
            value: '${stats.openDisputes}'),
      if (stats.pendingPayouts > 0)
        _AttentionCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Payout tertunda',
            value: '${stats.pendingPayouts}'),
      if (stats.flaggedItems > 0)
        _AttentionCard(
            icon: Icons.report_gmailerrorred_outlined,
            label: 'Barang ditandai',
            value: '${stats.flaggedItems}'),
      if (stats.suspendedUsers > 0)
        _AttentionCard(
            icon: Icons.block,
            label: 'User dibekukan',
            value: '${stats.suspendedUsers}'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Halo, $name 👋',
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        const Text('Ringkasan aktivitas PinjamAja hari ini.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        // Pendapatan
        Row(
          children: [
            Expanded(
              child: _MoneyCard(
                label: 'GMV',
                value: Formatters.rupiah(stats.gmv),
                icon: Icons.shopping_bag_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MoneyCard(
                label: 'Pendapatan Platform',
                value: Formatters.rupiah(stats.platformRevenue),
                icon: Icons.savings_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (attention.isNotEmpty) ...[
          const _SectionTitle('Perlu perhatian'),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 12, children: attention),
          const SizedBox(height: 20),
        ],

        const _SectionTitle('Ringkasan'),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatCard(
                icon: Icons.people_outline,
                label: 'Total Pengguna',
                value: '${stats.totalUsers}'),
            _StatCard(
                icon: Icons.inventory_2_outlined,
                label: 'Total Barang',
                value: '${stats.totalItems}'),
            _StatCard(
                icon: Icons.receipt_long_outlined,
                label: 'Total Booking',
                value: '${stats.totalBookings}'),
            _StatCard(
                icon: Icons.event_available_outlined,
                label: 'Booking Aktif',
                value: '${stats.activeBookings}'),
            _StatCard(
                icon: Icons.task_alt,
                label: 'Booking Selesai',
                value: '${stats.completedBookings}'),
            _StatCard(
                icon: Icons.verified_user_outlined,
                label: 'KYC Menunggu',
                value: '${stats.kycPending}'),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MoneyCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MoneyCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _AttentionCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      );
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => ListView(
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
}

class _DashboardError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DashboardError({required this.onRetry});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.cloud_off_outlined,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          const Text('Gagal memuat statistik.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text(
            'Tarik ke bawah untuk coba lagi, atau tekan tombol di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ),
        ],
      );
}