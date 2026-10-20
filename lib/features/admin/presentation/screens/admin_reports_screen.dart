import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/report.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String? _filter; // null = semua | open | reviewing | resolved | dismissed

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider(status: _filter));
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.reports,
      title: 'Laporan Pengguna',
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
                  _filterChip('Diabaikan', 'dismissed'),
                ],
              ),
            ),
          ),
          if (isWorking) const LinearProgressIndicator(),
          Expanded(
            child: reportsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(adminReportsProvider),
              ),
              data: (reports) {
                if (reports.isEmpty) {
                  return _emptyReports();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminReportsProvider);
                    await ref.read(
                        adminReportsProvider(status: _filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ReportCard(
                      report: reports[i],
                      onAction: () => _openActions(reports[i]),
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

  void _openActions(Report report) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text('Laporan ${report.targetTypeLabel}'),
              subtitle: Text(report.reason),
            ),
            const Divider(height: 1),
            if (report.status != 'reviewing')
              ListTile(
                leading: const Icon(Icons.visibility_outlined,
                    color: AppColors.info),
                title: const Text('Tandai sedang ditinjau'),
                onTap: () => _setStatus(report, 'reviewing'),
              ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.success),
              title: const Text('Selesaikan'),
              onTap: () => _setStatus(report, 'resolved', withNote: true),
            ),
            ListTile(
              leading:
                  const Icon(Icons.cancel_outlined, color: AppColors.error),
              title: const Text('Abaikan'),
              onTap: () => _setStatus(report, 'dismissed', withNote: true),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _setStatus(Report report, String status,
      {bool withNote = false}) async {
    Navigator.pop(context); // tutup sheet
    String? note;
    if (withNote) {
      note = await _askNote(
        status == 'resolved' ? 'Selesaikan laporan' : 'Abaikan laporan',
      );
      if (note == null) return; // batal
    }
    final ok = await ref.read(adminControllerProvider.notifier).updateReport(
          reportId: report.id,
          status: status,
          adminNote: (note == null || note.isEmpty) ? null : note,
        );
    if (!mounted) return;
    final err = ref.read(adminControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          ok ? 'Laporan diperbarui.' : 'Gagal: ${err ?? 'terjadi kesalahan'}'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  Future<String?> _askNote(String title) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Catatan admin (opsional)…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

Widget _emptyReports() => ListView(
      children: const [
        SizedBox(height: 80),
        Icon(Icons.inbox_outlined, size: 56, color: AppColors.success),
        SizedBox(height: 12),
        Text('Tidak ada laporan 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text('Belum ada laporan dengan filter ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    );

Color _statusColor(String s) => switch (s) {
      'open' => AppColors.secondary,
      'reviewing' => AppColors.info,
      'resolved' => AppColors.success,
      'dismissed' => AppColors.textTertiary,
      _ => AppColors.textSecondary,
    };

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onAction;
  const _ReportCard({required this.report, required this.onAction});

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
              _Badge(report.targetTypeLabel, AppColors.primary),
              const SizedBox(width: 6),
              _Badge(report.statusLabel, _statusColor(report.status)),
              const Spacer(),
              if (report.createdAt != null)
                Text(
                  Formatters.dateTime(report.createdAt!),
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.reason,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if (report.description != null &&
              report.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(report.description!,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 6),
          Text('Target ID: ${report.targetId}',
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 11)),
          if (report.adminNote != null && report.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Catatan admin: ${report.adminNote}',
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.more_horiz, size: 18),
              label: const Text('Tindak lanjut'),
            ),
          ),
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