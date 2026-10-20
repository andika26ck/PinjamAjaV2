import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../providers/report_provider.dart';

/// Jenis target laporan + alasan yang relevan untuk tiap jenis.
enum ReportTargetType {
  item('item', 'Barang'),
  user('user', 'Pengguna'),
  review('review', 'Ulasan'),
  chat('chat', 'Percakapan');

  final String value;
  final String label;
  const ReportTargetType(this.value, this.label);

  List<String> get reasons => switch (this) {
        ReportTargetType.item => const [
            'Barang palsu atau menyesatkan',
            'Konten/foto tidak pantas',
            'Dugaan penipuan',
            'Barang ilegal atau berbahaya',
            'Harga/deskripsi menyesatkan',
            'Lainnya',
          ],
        ReportTargetType.user => const [
            'Dugaan penipuan',
            'Pelecehan atau kata-kata kasar',
            'Akun palsu / impersonasi',
            'Spam atau promosi',
            'Lainnya',
          ],
        ReportTargetType.review => const [
            'Ulasan palsu',
            'Kata-kata kasar',
            'Spam atau promosi',
            'Tidak relevan',
            'Lainnya',
          ],
        ReportTargetType.chat => const [
            'Pelecehan atau kata-kata kasar',
            'Spam atau promosi',
            'Dugaan penipuan',
            'Konten tidak pantas',
            'Lainnya',
          ],
      };
}

/// Bottom sheet untuk mengirim laporan. Panggil via [ReportSheet.show].
class ReportSheet extends ConsumerStatefulWidget {
  final ReportTargetType type;
  final String targetId;
  const ReportSheet({super.key, required this.type, required this.targetId});

  static Future<void> show(
    BuildContext context, {
    required ReportTargetType type,
    required String targetId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ReportSheet(type: type, targetId: targetId),
      ),
    );
  }

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  String? _reason;
  final _descC = TextEditingController();

  @override
  void dispose() {
    _descC.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) {
      _snack('Pilih alasan pelaporan dulu, ya.', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = await ref.read(reportControllerProvider.notifier).submit(
          targetType: widget.type.value,
          targetId: widget.targetId,
          reason: reason,
          description: _descC.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      _snack('Laporan terkirim. Terima kasih — tim kami akan meninjau.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(reportControllerProvider).isLoading;

    ref.listen<AsyncValue<void>>(reportControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        _snack(e is AppException ? e.message : 'Gagal mengirim laporan.',
            error: true);
      });
    });

    return AbsorbPointer(
      absorbing: busy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: AppColors.error),
                const SizedBox(width: 8),
                Text('Laporkan ${widget.type.label}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih alasan pelaporan. Laporan kamu bersifat rahasia.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ...widget.type.reasons.map(
              (r) => RadioListTile<String>(
                value: r,
                groupValue: _reason,
                onChanged: (v) => setState(() => _reason = v),
                title: Text(r),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descC,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Tambahkan detail (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : _submit,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error),
                icon: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.send_outlined),
                label: Text(busy ? 'Mengirim...' : 'Kirim Laporan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol ikon 🚩 siap pakai — langsung membuka [ReportSheet].
class ReportButton extends StatelessWidget {
  final ReportTargetType targetType;
  final String targetId;
  final Color? tint;
  const ReportButton({
    super.key,
    required this.targetType,
    required this.targetId,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Laporkan',
      icon: Icon(Icons.flag_outlined, color: tint),
      onPressed: () => ReportSheet.show(
        context,
        type: targetType,
        targetId: targetId,
      ),
    );
  }
}