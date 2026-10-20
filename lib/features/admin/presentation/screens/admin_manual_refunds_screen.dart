import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../payment/data/models/deposit_refund_model.dart';
import '../../../payment/providers/manual_refund_provider.dart';
import '../widgets/admin_scaffold.dart';

class AdminManualRefundsScreen extends ConsumerStatefulWidget {
  const AdminManualRefundsScreen({super.key});

  @override
  ConsumerState<AdminManualRefundsScreen> createState() =>
      _AdminManualRefundsScreenState();
}

class _AdminManualRefundsScreenState
    extends ConsumerState<AdminManualRefundsScreen> {
  String? _filter = 'paid';
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(refundQueueProvider(_filter));
    return AdminScaffold(
      current: AdminSection.manualRefunds,
      title: 'Refund Deposit',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Perlu dikembalikan', 'paid'),
                  const SizedBox(width: 8),
                  _chip('Sudah dikembalikan', 'refunded'),
                  const SizedBox(width: 8),
                  _chip('Semua', null),
                ],
              ),
            ),
          ),
          if (_working) const LinearProgressIndicator(),
          Expanded(
            child: queueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat: $e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const Center(child: Text('Tidak ada data.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(refundQueueProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _card(rows[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) => ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
      );

  Widget _card(DepositRefundModel r) {
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
                child: Text(r.formattedDeposit,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              _statusBadge(r),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Deposit yang harus dikembalikan ke penyewa',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 8),
          Text(r.itemTitle ?? 'Barang',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Penyewa: ${r.renterName ?? '-'}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          if (r.bookingStatus != null)
            Text('Status sewa: ${r.bookingStatus}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          if (r.hasBankAccount)
            _bankBox(r)
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Penyewa belum mengisi rekening. Minta dia isi di menu '
                'Rekening Pencairan dulu sebelum deposit bisa dikembalikan.',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          if (r.isRefunded) ...[
            const SizedBox(height: 10),
            if (r.refundedAt != null)
              Text('Dikembalikan: ${r.refundedAt!.toLocal()}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            if (r.refundProofUrl != null) ...[
              const SizedBox(height: 6),
              _ProofThumb(path: r.refundProofUrl!),
            ],
          ],
          if (r.needsRefund && r.hasBankAccount) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _working ? null : () => _refund(r),
              icon: const Icon(Icons.assignment_return, size: 18),
              label: const Text('Tandai Deposit Dikembalikan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bankBox(DepositRefundModel r) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.bankName ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(r.accountNumber ?? '-',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ),
                IconButton(
                  tooltip: 'Salin nomor',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: r.accountNumber ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Nomor rekening disalin')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
            Text('a.n. ${r.accountName ?? '-'}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );

  Future<void> _refund(DepositRefundModel r) async {
    final noteC = TextEditingController();
    XFile? proof;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Kembalikan deposit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Konfirmasi kamu sudah transfer ${r.formattedDeposit} ke '
                  '${r.bankName} ${r.accountNumber} (a.n. ${r.accountName}).'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final f = await ImagePicker().pickImage(
                      source: ImageSource.gallery, imageQuality: 70);
                  if (f != null) setLocal(() => proof = f);
                },
                icon: const Icon(Icons.upload_file),
                label: Text(proof == null
                    ? 'Lampirkan bukti (opsional)'
                    : 'Bukti dipilih ✓'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteC,
                decoration: const InputDecoration(
                    hintText: 'Catatan (opsional)',
                    border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Konfirmasi')),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    setState(() => _working = true);
    try {
      final repo = ref.read(manualRefundRepositoryProvider);
      String? proofPath;
      if (proof != null) {
        proofPath = await repo.uploadRefundProof(
            renterId: r.renterId ?? 'unknown',
            paymentId: r.paymentId,
            filePath: proof!.path);
      }
      await repo.refundDeposit(
          paymentId: r.paymentId,
          proofPath: proofPath,
          note: noteC.text.trim().isEmpty ? null : noteC.text.trim());
      ref.invalidate(refundQueueProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deposit ditandai dikembalikan.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _statusBadge(DepositRefundModel r) {
    final String label;
    final Color color;
    if (r.isRefunded) {
      label = 'Dikembalikan';
      color = AppColors.success;
    } else if (r.needsRefund) {
      label = 'Perlu refund';
      color = AppColors.secondary;
    } else {
      label = '—';
      color = AppColors.textTertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ProofThumb extends ConsumerWidget {
  final String path;
  const _ProofThumb({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(manualRefundRepositoryProvider);
    return FutureBuilder<String?>(
      future: repo.signedRefundProofUrl(path),
      builder: (context, snap) {
        final url = snap.data;
        if (url == null) {
          return const SizedBox(
              height: 120, child: Center(child: CircularProgressIndicator()));
        }
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) =>
                Dialog(child: InteractiveViewer(child: Image.network(url))),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(url,
                height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}