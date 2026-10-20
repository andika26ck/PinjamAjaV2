import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/item.dart';
import '../../providers/booking_provider.dart';
import 'booking_success_screen.dart';

enum PaymentMethod {
  transferBank('Transfer Bank', Icons.account_balance_outlined),
  gopay('GoPay', Icons.account_balance_wallet_outlined),
  ovo('OVO', Icons.account_balance_wallet_outlined),
  qris('QRIS', Icons.qr_code_2_outlined);

  final String label;
  final IconData icon;
  const PaymentMethod(this.label, this.icon);
}

class PaymentScreen extends ConsumerStatefulWidget {
  final Booking booking;
  final Item? item;
  const PaymentScreen({super.key, required this.booking, this.item});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.transferBank;

  Future<void> _pay() async {
    final paid =
        await ref.read(bookingControllerProvider.notifier).pay(widget.booking.id);
    if (!mounted || paid == null) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => BookingSuccessScreen(booking: paid),
    ));
  }

  void _payLater() {
    // Booking sudah tersimpan sebagai 'awaiting_payment' (berlaku 24 jam).
    // Cukup arahkan ke daftar booking; user bisa lanjut bayar kapan saja
    // dari tab "Belum Bayar".
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Booking disimpan. Selesaikan pembayaran dalam 24 jam lewat tab "Belum Bayar".'),
      ),
    );
    context.go(AppRoutes.myBookings);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(bookingControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e is AppException ? e.message : 'Pembayaran gagal.'),
          backgroundColor: AppColors.error,
        ));
      });
    });
    final loading = ref.watch(bookingControllerProvider).isLoading;
    final b = widget.booking;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total pembayaran',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  Formatters.rupiah(b.totalPrice),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                ),
                if (widget.item != null) ...[
                  const SizedBox(height: 4),
                  Text(widget.item!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Pilih metode pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...PaymentMethod.values.map((m) {
            final selected = m == _method;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _method = m),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.06)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(m.icon, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(m.label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Ini pembayaran simulasi untuk keperluan demo. Tidak ada transaksi '
            'uang sungguhan.',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: loading ? null : _pay,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        'Bayar Sekarang · ${Formatters.rupiah(b.totalPrice)}'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: loading ? null : _payLater,
                icon: const Icon(Icons.schedule, size: 18),
                label: const Text('Bayar Nanti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}