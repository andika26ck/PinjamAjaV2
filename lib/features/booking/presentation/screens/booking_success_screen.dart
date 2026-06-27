import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../data/models/booking.dart';

class BookingSuccessScreen extends StatefulWidget {
  final Booking booking;
  const BookingSuccessScreen({super.key, required this.booking});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _bookingNo {
    final raw = widget.booking.id.replaceAll('-', '');
    final take = raw.length < 8 ? raw.length : 8;
    return '#${raw.substring(0, take).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 140,
                width: 140,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) =>
                      CustomPaint(painter: _CheckPainter(_controller.value)),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Pembayaran Berhasil!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Permintaan sewa kamu sudah dikirim ke pemilik barang untuk '
                'dikonfirmasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Nomor Booking: ',
                        style: TextStyle(color: AppColors.textSecondary)),
                    Text(_bookingNo,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context
                      .go(AppRoutes.bookingDetailPath(widget.booking.id)),
                  child: const Text('Lihat Detail Booking'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lingkaran yang tumbuh + centang yang tergambar bertahap (0..1).
class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final circleScale = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));

    final fill = Paint()
      ..color = AppColors.success.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * circleScale, fill);

    final ring = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius * 0.92 * circleScale, ring);

    final checkProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    if (checkProgress <= 0) return;

    final p1 = Offset(center.dx - radius * 0.38, center.dy + radius * 0.02);
    final p2 = Offset(center.dx - radius * 0.08, center.dy + radius * 0.30);
    final p3 = Offset(center.dx + radius * 0.42, center.dy - radius * 0.30);

    final firstLen = (p2 - p1).distance;
    final secondLen = (p3 - p2).distance;
    final drawn = (firstLen + secondLen) * checkProgress;

    final path = Path()..moveTo(p1.dx, p1.dy);
    if (drawn <= firstLen) {
      final t = firstLen == 0 ? 0.0 : drawn / firstLen;
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = secondLen == 0 ? 0.0 : (drawn - firstLen) / secondLen;
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }

    final check = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, check);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.progress != progress;
}