import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/payout.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminPayoutsScreen extends ConsumerStatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  ConsumerState<AdminPayoutsScreen> createState() =>
      _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends ConsumerState<AdminPayoutsScreen> {
  String? _filter; // null = semua | pending | processed | completed | failed

  @override
  Widget build(BuildContext context) {
    final payoutsAsync = ref.watch(adminPayoutsProvider(status: _filter));
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.payouts,
      title: 'Pencairan Dana',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Semua', null),
                  const SizedBox(width: 8),
                  _filterChip('Menunggu', 'pending'),
                  const SizedBox(width: 8),
                  _filterChip('Diproses', 'processed'),
                  const SizedBox(width: 8),
                  _filterChip('Selesai', 'completed'),
                  const SizedBox(width: 8),
                  _filterChip('Gagal', 'failed'),
                ],
              ),
            ),
          ),
          if (isWorking) const LinearProgressIndicator(),
          Expanded(
            child: payoutsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(adminPayoutsProvider),
              ),
              data: (payouts) {
                if (payouts.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada pencairan ditemukan.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminPayoutsProvider);
                    await ref.read(
                        adminPayoutsProvider(status: _filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: payouts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _PayoutCard(
                      payout: payouts[i],
                      onRelease: () => _release(payouts[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Future<void> _release(Payout payout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cairkan Pencairan'),
        content: Text(
          'Cairkan dana ${Formatters.rupiah(payout.netAmount)} ke pemilik? '
          'Tindakan ini menandai pencairan sebagai selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cairkan'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await ref
        .read(adminControllerProvider.notifier)
        .releasePayout(payout.id);
    if (!mounted) return;
    final err = ref.read(adminControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Pencairan berhasil dicairkan.'
          : 'Gagal: ${err ?? 'terjadi kesalahan'}'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }
}

Color _payoutColor(String s) => switch (s) {
      'pending' => AppColors.secondary,
      'processed' => AppColors.info,
      'completed' => AppColors.success,
      'failed' => AppColors.error,
      _ => AppColors.textSecondary,
    };

class _PayoutCard extends StatelessWidget {
  final Payout payout;
  final VoidCallback onRelease;
  const _PayoutCard({required this.payout, required this.onRelease});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Formatters.rupiah(payout.netAmount),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              _Badge(payout.statusLabel, _payoutColor(payout.status)),
            ],
          ),
          const SizedBox(height: 8),
          _row('Bruto', Formatters.rupiah(payout.grossAmount)),
          _row('Komisi platform',
              '- ${Formatters.rupiah(payout.platformFee)}'),
          _row('Diterima pemilik', Formatters.rupiah(payout.netAmount)),
          const SizedBox(height: 6),
          Text('Pemilik: ${payout.ownerId}',
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 11)),
          if (payout.scheduledAt != null)
            Text('Dijadwalkan: ${Formatters.dateTime(payout.scheduledAt!)}',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 11)),
          if (payout.processedAt != null)
            Text('Diproses: ${Formatters.dateTime(payout.processedAt!)}',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 11)),
          if (payout.isPending) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onRelease,
                icon: const Icon(
                    Icons.account_balance_wallet_outlined, size: 18),
                label: const Text('Cairkan'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}