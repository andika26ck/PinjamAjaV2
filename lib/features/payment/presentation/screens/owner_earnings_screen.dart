import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/payment_provider.dart';

class OwnerEarningsScreen extends ConsumerWidget {
  const OwnerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(ownerPayoutsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pendapatan Saya')),
      body: payoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (payouts) {
          double totalNet = 0, pending = 0;
          for (final p in payouts) {
            final net = (p['net_amount'] as num?)?.toDouble() ?? 0;
            totalNet += net;
            if (p['status'] == 'pending') pending += net;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _summary('Total Bersih', Formatters.rupiah(totalNet), AppColors.success)),
                  const SizedBox(width: 12),
                  Expanded(child: _summary('Menunggu', Formatters.rupiah(pending), AppColors.secondary)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Riwayat Payout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              if (payouts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('Belum ada pendapatan.')),
                ),
              ...payouts.map((p) {
                final title = (p['booking']?['item']?['title'] ?? 'Barang').toString();
                final gross = (p['gross_amount'] as num?)?.toDouble() ?? 0;
                final fee = (p['platform_fee'] as num?)?.toDouble() ?? 0;
                final net = (p['net_amount'] as num?)?.toDouble() ?? 0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                            _statusBadge(p['status'] as String? ?? 'pending'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _line('Bruto', Formatters.rupiah(gross), AppColors.textSecondary),
                        _line('Biaya platform', '- ${Formatters.rupiah(fee)}', AppColors.error),
                        _line('Diterima', Formatters.rupiah(net), AppColors.success, bold: true),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(String label, String value, Color color) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
        ),
      );

  Widget _line(String k, String v, Color c, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(v, style: TextStyle(color: c, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      );

  Widget _statusBadge(String status) {
    Color c;
    switch (status) {
      case 'completed':
        c = AppColors.success;
        break;
      case 'processed':
        c = AppColors.secondary;
        break;
      case 'failed':
        c = AppColors.error;
        break;
      default:
        c = AppColors.textTertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}