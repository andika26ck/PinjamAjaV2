import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../payment/data/models/manual_payment_model.dart';
import '../../../payment/providers/manual_payment_provider.dart';
import '../widgets/admin_scaffold.dart';

class AdminManualPaymentsScreen extends ConsumerStatefulWidget {
  const AdminManualPaymentsScreen({super.key});

  @override
  ConsumerState<AdminManualPaymentsScreen> createState() =>
      _AdminManualPaymentsScreenState();
}

class _AdminManualPaymentsScreenState
    extends ConsumerState<AdminManualPaymentsScreen> {
  String? _filter = 'pending';
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(manualQueueProvider(_filter));
    return AdminScaffold(
      current: AdminSection.manualPayments,
      title: 'Bayar Manual',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Menunggu', 'pending'),
                  const SizedBox(width: 8),
                  _chip('Diterima', 'paid'),
                  const SizedBox(width: 8),
                  _chip('Ditolak', 'failed'),
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
                  return const Center(
                      child: Text('Tidak ada pembayaran manual.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(manualQueueProvider),
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

  Widget _card(Map<String, dynamic> row) {
    final p = ManualPaymentModel.fromJson(row);
    final title = (row['booking']?['item']?['title'] ?? 'Barang').toString();
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
                child: Text(p.formattedTotal,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              _statusBadge(p.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Pengirim: ${p.senderName ?? '-'} · ${p.channelLabel}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text('Booking: ${p.bookingId}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 10),
          if (p.hasProof) _ProofThumb(path: p.proofUrl!),
          if (p.status == 'pending' && p.hasProof) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error),
                    onPressed: _working ? null : () => _reject(p),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _working ? null : () => _approve(p),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
          if (p.isRejected && p.rejectedReason != null) ...[
            const SizedBox(height: 8),
            Text('Ditolak: ${p.rejectedReason}',
                style: const TextStyle(fontSize: 12, color: AppColors.error)),
          ],
        ],
      ),
    );
  }

  Future<void> _approve(ManualPaymentModel p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terima pembayaran?'),
        content: Text(
            'Pastikan dana ${p.formattedTotal} sudah masuk ke rekening. '
            'Booking akan diteruskan ke pemilik untuk dikonfirmasi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Terima')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => ref
        .read(manualPaymentRepositoryProvider)
        .verifyManualPayment(paymentId: p.id, approve: true));
  }

  Future<void> _reject(ManualPaymentModel p) async {
    final c = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak pembayaran'),
        content: TextField(
          controller: c,
          maxLines: 2,
          decoration: const InputDecoration(
              hintText: 'Alasan penolakan (mis. bukti tidak sesuai)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(
                ctx, c.text.trim().isEmpty ? 'Bukti ditolak' : c.text.trim()),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (note == null) return;
    await _run(() => ref
        .read(manualPaymentRepositoryProvider)
        .verifyManualPayment(paymentId: p.id, approve: false, note: note));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _working = true);
    try {
      await action();
      ref.invalidate(manualQueueProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil diproses.')));
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

  Widget _statusBadge(String s) {
    final (label, color) = switch (s) {
      'paid' => ('Diterima', AppColors.success),
      'failed' => ('Ditolak', AppColors.error),
      _ => ('Menunggu', AppColors.secondary),
    };
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
    final repo = ref.watch(manualPaymentRepositoryProvider);
    return FutureBuilder<String?>(
      future: repo.signedProofUrl(path),
      builder: (context, snap) {
        final url = snap.data;
        if (url == null) {
          return Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) =>
                Dialog(child: InteractiveViewer(child: Image.network(url))),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        );
      },
    );
  }
}