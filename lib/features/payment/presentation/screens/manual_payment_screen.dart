import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/models/manual_payment_model.dart';
import '../../data/models/payment_account_model.dart';
import '../../providers/manual_payment_provider.dart';

class ManualPaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const ManualPaymentScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ManualPaymentScreen> createState() =>
      _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends ConsumerState<ManualPaymentScreen> {
  final _senderC = TextEditingController();
  ManualPaymentModel? _payment;
  String? _error;
  bool _loading = true;
  bool _submitting = false;
  XFile? _proof;
  PaymentAccountModel? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    try {
      final p = await ref
          .read(manualPaymentRepositoryProvider)
          .createOrGetManualPayment(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _payment = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _senderC.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _proof = file);
  }

  void _snack(String m, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  Future<void> _submit() async {
    if (_selectedAccount == null) {
      _snack('Pilih rekening / QRIS tujuan dulu.');
      return;
    }
    if (_senderC.text.trim().isEmpty) {
      _snack('Isi nama pengirim transfer.');
      return;
    }
    if (_proof == null) {
      _snack('Unggah bukti transfer dulu, ya.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(manualPaymentRepositoryProvider);
      final path = await repo.uploadProof(
        bookingId: widget.bookingId,
        filePath: _proof!.path,
      );
      await repo.submitProof(
        bookingId: widget.bookingId,
        proofPath: path,
        senderName: _senderC.text.trim(),
        channel: _selectedAccount!.isQris ? 'qris' : 'bank_transfer',
        accountId: _selectedAccount!.id,
      );
      if (mounted) _snack('Bukti terkirim. Menunggu verifikasi admin.');
    } catch (e) {
      if (mounted) _snack('Gagal mengirim bukti: $e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigasi saat admin memverifikasi (status -> paid).
    ref.listen(manualPaymentByBookingProvider(widget.bookingId), (_, next) {
      final p = next.valueOrNull;
      if (p != null && p.isPaid && mounted) {
        context.pushReplacement(AppRoutes.paymentSuccessPath(widget.bookingId));
      }
    });

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bayar Manual')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Gagal memuat pembayaran:\n$_error',
                textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final live =
        ref.watch(manualPaymentByBookingProvider(widget.bookingId)).valueOrNull;
    final payment = live ?? _payment!;
    final waiting = payment.awaitingVerification;

    return Scaffold(
      appBar: AppBar(title: const Text('Bayar Manual')),
      body: waiting
          ? _waitingView(payment)
          : _formView(payment, payment.isRejected),
      bottomNavigationBar: waiting
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text('Kirim Bukti Pembayaran'),
                ),
              ),
            ),
    );
  }

  Widget _formView(ManualPaymentModel payment, bool rejected) {
    final accountsAsync = ref.watch(paymentAccountsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _amountCard(payment),
        if (rejected && payment.rejectedReason != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bukti sebelumnya ditolak: ${payment.rejectedReason}. '
                    'Silakan transfer ulang & kirim bukti yang benar.',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('1. Transfer ke salah satu tujuan berikut',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        accountsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Gagal memuat rekening: $e'),
          data: (accounts) {
            if (accounts.isEmpty) {
              return const Text('Belum ada rekening tujuan. Hubungi admin.');
            }
            return Column(
              children: [for (final a in accounts) _accountTile(a)],
            );
          },
        ),
        const SizedBox(height: 20),
        const Text('2. Isi nama pengirim & unggah bukti',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _senderC,
          decoration: const InputDecoration(
            labelText: 'Nama pengirim (sesuai rekening pengirim)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _proofPicker(),
        const SizedBox(height: 8),
        const Text(
          'Pastikan nominal transfer tepat sama dengan total di atas agar '
          'verifikasi cepat.',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _amountCard(ManualPaymentModel p) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total yang harus ditransfer',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(p.formattedTotal,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  tooltip: 'Salin nominal',
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: p.totalAmount.round().toString()));
                    _snack('Nominal disalin');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _accountTile(PaymentAccountModel a) {
    final selected = _selectedAccount?.id == a.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedAccount = a),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(child: a.isQris ? _qrisContent(a) : _bankContent(a)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrisContent(PaymentAccountModel a) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (a.qrisImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(a.qrisImageUrl!,
                  height: 220, fit: BoxFit.contain),
            )
          else
            const Text('QRIS belum tersedia.'),
          if (a.accountName != null) ...[
            const SizedBox(height: 6),
            Text('a.n. ${a.accountName}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ],
      );

  Widget _bankContent(PaymentAccountModel a) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a.bankName ?? a.label,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(a.accountNumber ?? '-',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ),
              if (a.accountNumber != null)
                IconButton(
                  tooltip: 'Salin nomor',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: a.accountNumber!));
                    _snack('Nomor rekening disalin');
                  },
                  icon: const Icon(Icons.copy, size: 18),
                ),
            ],
          ),
          if (a.accountName != null)
            Text('a.n. ${a.accountName}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
        ],
      );

  Widget _proofPicker() => Row(
        children: [
          if (_proof != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(_proof!.path),
                  height: 72, width: 72, fit: BoxFit.cover),
            )
          else
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.textTertiary),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickProof,
              icon: const Icon(Icons.upload_file),
              label:
                  Text(_proof == null ? 'Pilih Bukti Transfer' : 'Ganti Bukti'),
            ),
          ),
        ],
      );

  Widget _waitingView(ManualPaymentModel p) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.hourglass_top, size: 72, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text('Menunggu Verifikasi Admin',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Bukti pembayaranmu sudah terkirim. Admin akan mengecek dan '
            'mengonfirmasi. Status diperbarui otomatis di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _kv('Total', p.formattedTotal),
                  _kv('Pengirim', p.senderName ?? '-'),
                  _kv('Metode', p.channelLabel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                context.go(AppRoutes.bookingDetailPath(widget.bookingId)),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Text('Lihat Detail Booking'),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.textSecondary)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}