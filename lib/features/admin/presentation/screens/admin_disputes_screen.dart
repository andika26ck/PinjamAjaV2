import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/dispute.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminDisputesScreen extends ConsumerStatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  ConsumerState<AdminDisputesScreen> createState() =>
      _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends ConsumerState<AdminDisputesScreen> {
  String? _filter; // null = semua | open | reviewing | resolved | rejected

  @override
  Widget build(BuildContext context) {
    final disputesAsync = ref.watch(adminDisputesProvider(status: _filter));
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.disputes,
      title: 'Sengketa',
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
                  _filterChip('Baru', 'open'),
                  const SizedBox(width: 8),
                  _filterChip('Ditinjau', 'reviewing'),
                  const SizedBox(width: 8),
                  _filterChip('Selesai', 'resolved'),
                  const SizedBox(width: 8),
                  _filterChip('Ditolak', 'rejected'),
                ],
              ),
            ),
          ),
          if (isWorking) const LinearProgressIndicator(),
          Expanded(
            child: disputesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(adminDisputesProvider),
              ),
              data: (disputes) {
                if (disputes.isEmpty) return _emptyDisputes();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminDisputesProvider);
                    await ref.read(
                        adminDisputesProvider(status: _filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: disputes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _DisputeCard(
                      dispute: disputes[i],
                      onReview: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              _DisputeResolveScreen(dispute: disputes[i]),
                        ),
                      ),
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
}

Widget _emptyDisputes() => ListView(
      children: const [
        SizedBox(height: 80),
        Icon(Icons.gavel_outlined, size: 56, color: AppColors.success),
        SizedBox(height: 12),
        Text('Tidak ada sengketa 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text('Belum ada sengketa dengan filter ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    );

Color _disputeColor(String s) => switch (s) {
      'open' => AppColors.secondary,
      'reviewing' => AppColors.info,
      'resolved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.textSecondary,
    };

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;
  final VoidCallback onReview;
  const _DisputeCard({required this.dispute, required this.onReview});

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
              _Badge(dispute.statusLabel, _disputeColor(dispute.status)),
              const Spacer(),
              if (dispute.createdAt != null)
                Text(Formatters.dateTime(dispute.createdAt!),
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(dispute.reason,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if (dispute.description != null &&
              dispute.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(dispute.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 6),
          Text('Booking: ${dispute.bookingId}',
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 11)),
          if (dispute.status == 'resolved') ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keputusan: ${Dispute.resolutionLabel(dispute.resolution)}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (dispute.refundAmount != null)
                    Text('Nominal: ${Formatters.rupiah(dispute.refundAmount!)}',
                        style: const TextStyle(fontSize: 12)),
                  if (dispute.resolutionNote != null &&
                      dispute.resolutionNote!.isNotEmpty)
                    Text('Catatan: ${dispute.resolutionNote}',
                        style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReview,
              icon: Icon(
                  dispute.isOpen
                      ? Icons.gavel_outlined
                      : Icons.visibility_outlined,
                  size: 18),
              label: Text(
                  dispute.isOpen ? 'Tinjau & Putuskan' : 'Lihat detail'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisputeResolveScreen extends ConsumerStatefulWidget {
  final Dispute dispute;
  const _DisputeResolveScreen({required this.dispute});

  @override
  ConsumerState<_DisputeResolveScreen> createState() =>
      _DisputeResolveScreenState();
}

class _DisputeResolveScreenState
    extends ConsumerState<_DisputeResolveScreen> {
  String _resolution = 'refund_renter';
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  static const _resolutions = [
    'refund_renter',
    'pay_owner',
    'partial_refund',
    'deduct_deposit',
    'no_action',
  ];

  bool get _needsAmount =>
      _resolution == 'refund_renter' ||
      _resolution == 'partial_refund' ||
      _resolution == 'deduct_deposit';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;
    final isWorking = ref.watch(adminControllerProvider).isLoading;
    final resolved = d.status == 'resolved';
    return Scaffold(
      appBar: AppBar(title: const Text('Tinjau Sengketa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Alasan', d.reason),
          _field('Deskripsi', d.description),
          _field('Booking ID', d.bookingId),
          _field('Diajukan',
              d.createdAt == null ? null : Formatters.dateTime(d.createdAt!)),
          if (d.evidenceUrls.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Bukti',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: d.evidenceUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    d.evidenceUrls[i],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined,
                          color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const Divider(height: 32),
          if (resolved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sengketa sudah diselesaikan',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success)),
                  const SizedBox(height: 4),
                  Text(
                      'Keputusan: ${Dispute.resolutionLabel(d.resolution)}'),
                  if (d.refundAmount != null)
                    Text('Nominal: ${Formatters.rupiah(d.refundAmount!)}'),
                  if (d.resolutionNote != null &&
                      d.resolutionNote!.isNotEmpty)
                    Text('Catatan: ${d.resolutionNote}'),
                ],
              ),
            )
          else ...[
            const Text('Keputusan',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final r in _resolutions)
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: r,
                groupValue: _resolution,
                title: Text(Dispute.resolutionLabel(r)),
                onChanged: isWorking
                    ? null
                    : (v) => setState(() => _resolution = v!),
              ),
            if (_needsAmount) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  hintText: 'mis. 50000',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan keputusan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isWorking ? null : _apply,
              icon: const Icon(Icons.gavel),
              label: const Text('Terapkan Keputusan'),
            ),
            if (isWorking) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ],
      ),
    );
  }

  Widget _field(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value?.isNotEmpty == true ? value! : '—',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _apply() async {
    num? amount;
    if (_needsAmount) {
      final raw = _amountCtrl.text
          .trim()
          .replaceAll('.', '')
          .replaceAll(',', '');
      if (raw.isNotEmpty) amount = num.tryParse(raw);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Masukkan nominal yang valid.'),
        ));
        return;
      }
    }
    final note = _noteCtrl.text.trim();
    final ok =
        await ref.read(adminControllerProvider.notifier).resolveDispute(
              disputeId: widget.dispute.id,
              resolution: _resolution,
              note: note.isEmpty ? null : note,
              refundAmount: amount,
            );
    if (!mounted) return;
    final err = ref.read(adminControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Sengketa diselesaikan.'
          : 'Gagal: ${err ?? 'terjadi kesalahan'}'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
    if (ok && context.mounted) Navigator.of(context).pop();
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