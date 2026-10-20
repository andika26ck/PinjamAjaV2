import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../data/dispute_repository.dart';
import '../../providers/dispute_provider.dart';

/// Daftar alasan sengketa (Bahasa Indonesia).
const _disputeReasons = <String>[
  'Barang rusak atau tidak berfungsi',
  'Barang tidak sesuai deskripsi',
  'Barang tidak dikembalikan',
  'Pengembalian terlambat',
  'Deposit tidak dikembalikan',
  'Biaya tidak sesuai kesepakatan',
  'Pihak lain tidak kooperatif',
  'Lainnya',
];

class DisputeSubmissionScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String? againstId;
  const DisputeSubmissionScreen({
    super.key,
    required this.bookingId,
    this.againstId,
  });

  @override
  ConsumerState<DisputeSubmissionScreen> createState() =>
      _DisputeSubmissionScreenState();
}

class _DisputeSubmissionScreenState
    extends ConsumerState<DisputeSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descC = TextEditingController();
  String? _reason;
  final _evidences = <_EvidenceEntry>[];

  static const int _maxEvidence = 5;

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

  Future<void> _pickEvidence() async {
    if (_evidences.length >= _maxEvidence) {
      _snack('Maksimal $_maxEvidence bukti.');
      return;
    }
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      for (final f in picked) {
        if (_evidences.length >= _maxEvidence) break;
        final bytes = await f.readAsBytes();
        final ext = f.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        _evidences.add(_EvidenceEntry(bytes: bytes, ext: ext));
      }
      setState(() {});
    } catch (_) {
      _snack('Gagal memilih foto bukti.', error: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_reason == null) {
      _snack('Pilih alasan sengketa dulu, ya.', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = await ref.read(disputeControllerProvider.notifier).submit(
          bookingId: widget.bookingId,
          againstId: widget.againstId,
          reason: _reason!,
          description: _descC.text,
          evidences: [
            for (final e in _evidences)
              EvidenceUpload(bytes: e.bytes, fileExtension: e.ext),
          ],
        );
    if (!mounted) return;
    if (ok) {
      _snack('Sengketa diajukan. Tim kami akan meninjau secepatnya.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(disputeControllerProvider).isLoading;

    ref.listen<AsyncValue<void>>(disputeControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        _snack(e is AppException ? e.message : 'Terjadi kesalahan.',
            error: true);
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Sengketa')),
      body: AbsorbPointer(
        absorbing: busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.gavel_outlined,
                        color: AppColors.warning, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ajukan sengketa kalau ada masalah serius pada '
                        'transaksi ini. Sertakan bukti foto agar admin bisa '
                        'menilai dengan adil.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Alasan sengketa',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              ..._disputeReasons.map(
                (r) => RadioListTile<String>(
                  value: r,
                  groupValue: _reason,
                  onChanged: (v) => setState(() => _reason = v),
                  title: Text(r),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Penjelasan',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descC,
                maxLines: 5,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'Ceritakan kronologi masalahnya...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Tolong jelaskan minimal 10 karakter'
                    : null,
              ),
              const SizedBox(height: 12),
              Text('Bukti foto (maks $_maxEvidence, opsional)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              _evidenceGrid(),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: busy ? null : _submit,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error),
                icon: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.gavel_outlined),
                label: Text(busy ? 'Mengirim...' : 'Ajukan Sengketa'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dengan mengajukan, kamu menyatakan informasi yang diberikan '
                'benar.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _evidenceGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < _evidences.length; i++)
          _EvidenceThumb(
            bytes: _evidences[i].bytes,
            onRemove: () => setState(() => _evidences.removeAt(i)),
          ),
        if (_evidences.length < _maxEvidence)
          GestureDetector(
            onTap: _pickEvidence,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: AppColors.textTertiary),
                  SizedBox(height: 4),
                  Text('Tambah',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EvidenceEntry {
  final Uint8List bytes;
  final String ext;
  const _EvidenceEntry({required this.bytes, required this.ext});
}

class _EvidenceThumb extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;
  const _EvidenceThumb({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes,
              width: 88, height: 88, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child:
                  const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}