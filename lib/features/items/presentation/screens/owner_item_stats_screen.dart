import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/item.dart';
import '../../providers/owner_stats_provider.dart';

class OwnerItemStatsScreen extends ConsumerWidget {
  final Item item;
  const OwnerItemStatsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(itemStatsProvider(item.id));
    return Scaffold(
      appBar: AppBar(title: Text(item.title, overflow: TextOverflow.ellipsis)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is AppException ? e.message : 'Gagal memuat statistik.'),
        ),
        data: (s) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                _StatCard(
                  label: 'Total Pendapatan',
                  value: Formatters.rupiah(s.totalRevenue),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Booking Aktif',
                  value: '${s.activeBookings}',
                  icon: Icons.event_available_outlined,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  label: 'Rating Rata-rata',
                  value: s.avgRating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Pendapatan 7 Hari Terakhir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: CustomPaint(
                size: Size.infinite,
                painter: _BarChartPainter(
                    s.last7DaysRevenue, s.last7DaysLabels),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Booking Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (s.recentBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Belum ada booking.',
                    style: TextStyle(color: AppColors.textTertiary)),
              )
            else
              ...s.recentBookings.map((b) => _BookingTile(booking: b)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;
  const _BookingTile({required this.booking});

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    const b = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${b[d.month - 1]}';
  }

  Color get _statusColor => switch (booking.status) {
        'completed' => AppColors.statusCompleted,
        'cancelled' => AppColors.statusCancelled,
        'pending' => AppColors.statusPending,
        _ => AppColors.statusActive,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_fmt(booking.startDate)} - ${_fmt(booking.endDate)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${booking.totalDay} hari',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.rupiah(booking.totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                      fontSize: 11,
                      color: _statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bar chart sederhana (manual) memakai CustomPaint.
class _BarChartPainter extends CustomPainter {
  final List<int> values;
  final List<DateTime> labels;
  _BarChartPainter(this.values, this.labels);

  static const _wd = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const labelH = 22.0;
    final chartH = size.height - labelH;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final n = values.length;
    final slot = size.width / n;
    final barW = slot * 0.5;
    final barPaint = Paint()..color = AppColors.primary;
    final trackPaint = Paint()..color = AppColors.surfaceVariant;

    for (var i = 0; i < n; i++) {
      final cx = slot * i + slot / 2;
      final left = cx - barW / 2;
      final radius = const Radius.circular(6);

      final track = RRect.fromLTRBR(left, 0, left + barW, chartH, radius);
      canvas.drawRRect(track, trackPaint);

      final h = maxV == 0 ? 0.0 : (values[i] / maxV) * chartH;
      final bar =
          RRect.fromLTRBR(left, chartH - h, left + barW, chartH, radius);
      canvas.drawRRect(bar, barPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: _wd[(labels[i].weekday - 1) % 7],
          style: const TextStyle(
              fontSize: 10, color: AppColors.textTertiary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.values != values || old.labels != labels;
}