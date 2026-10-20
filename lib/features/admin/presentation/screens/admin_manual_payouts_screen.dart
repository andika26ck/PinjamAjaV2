import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../payment/data/models/payout_model.dart';
import '../../../payment/providers/manual_payout_provider.dart';
import '../widgets/admin_scaffold.dart';

class AdminManualPayoutsScreen extends ConsumerStatefulWidget {
  const AdminManualPayoutsScreen({super.key});

  @override
  ConsumerState<AdminManualPayoutsScreen> createState() =>
      _AdminManualPayoutsScreenState();
}

class _AdminManualPayoutsScreenState
    extends ConsumerState<AdminManualPayoutsScreen> {
  String? _filter = 'pending';
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(payoutQueueProvider(_filter));
    return AdminScaffold(
      current: AdminSection.manualPayouts,
      title: 'Pencairan ke Pemilik',
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
                  _chip('Sudah dicairkan', 'completed'),
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
                  return const Center(child: Text('Tidak ada pencairan.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(payoutQueueProvider),
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

  Widget _card(ManualPayoutModel p) {
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
                child: Text(p.formattedNet,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              _statusBadge(p.status),
            ],
          ),
          const SizedBox(height: 2),
          Text('Net untuk pemilik (bruto ${p.formattedGross})',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 8),
          Text(p.itemTitle ?? 'Barang',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Pemilik: ${p.ownerName ?? '-'}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          if (p.hasPayoutAccount)
            _bankBox(p)
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Pemilik belum mengisi rekening pencairan. Minta dia mengisi '
                'di menu Rekening Pencairan dulu.',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          if (p.isCompleted) ...[
            const SizedBox(height: 10),
            if (p.transferredAt != null)
              Text('Ditransfer: ${p.transferredAt!.toLocal()}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            if (p.transferProofUrl != null) ...[
              const SizedBox(height: 6),
              _ProofThumb(path: p.transferProofUrl!),
            ],
          ],
          if (p.isPending && p.hasPayoutAccount) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _working ? null : () => _complete(p),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Tandai Sudah Ditransfer'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bankBox(ManualPayoutModel p) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.payoutBankName ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(p.payoutAccountNumber ?? '-',
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
                        ClipboardData(text: p.payoutAccountNumber ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Nomor rekening disalin')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
            Text('a.n. ${p.payoutAccountName ?? '-'}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );

  Future<void> _complete(ManualPayoutModel p) async {
    final noteC = TextEditingController();
    XFile? proof;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Tandai sudah ditransfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Konfirmasi kamu sudah transfer ${p.formattedNet} ke '
                  '${p.payoutBankName} ${p.payoutAccountNumber} '
                  '(a.n. ${p.payoutAccountName}).'),
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
      final repo = ref.read(manualPayoutRepositoryProvider);
      String? proofPath;
      if (proof != null) {
        proofPath = await repo.uploadPayoutProof(
            ownerId: p.ownerId, payoutId: p.id, filePath: proof!.path);
      }
      await repo.completePayout(
          payoutId: p.id,
          proofPath: proofPath,
          note: noteC.text.trim().isEmpty ? null : noteC.text.trim());
      ref.invalidate(payoutQueueProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pencairan ditandai selesai.')));
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

  // Status badge SINKRON dengan owner_earnings_screen.dart
  Widget _statusBadge(String s) {
    final (label, color) = switch (s) {
      'completed' => ('Sudah dicairkan', AppColors.success),
      'failed' => ('Gagal', AppColors.error),
      'processed' => ('Diproses', AppColors.info),
      _ => ('Menunggu pencairan', AppColors.secondary),
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
    final repo = ref.watch(manualPayoutRepositoryProvider);
    return FutureBuilder<String?>(
      future: repo.signedPayoutProofUrl(path),
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