import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../data/models/user_profile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/kyc_provider.dart';

class KycSubmissionScreen extends ConsumerStatefulWidget {
  const KycSubmissionScreen({super.key});

  @override
  ConsumerState<KycSubmissionScreen> createState() =>
      _KycSubmissionScreenState();
}

class _KycSubmissionScreenState extends ConsumerState<KycSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _nikC = TextEditingController();

  Uint8List? _idBytes;
  String _idExt = 'jpg';
  Uint8List? _selfieBytes;
  String _selfieExt = 'jpg';

  bool _prefilled = false;

  @override
  void dispose() {
    _nameC.dispose();
    _nikC.dispose();
    super.dispose();
  }

  void _prefill(UserProfile p) {
    if (_prefilled) return;
    _nameC.text = p.kycFullName ?? p.name ?? '';
    _nikC.text = p.kycIdNumber ?? '';
    _prefilled = true;
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  Future<void> _pick({required bool isSelfie}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final ext = picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      setState(() {
        if (isSelfie) {
          _selfieBytes = bytes;
          _selfieExt = ext;
        } else {
          _idBytes = bytes;
          _idExt = ext;
        }
      });
    } catch (_) {
      _snack('Gagal memilih foto.', error: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idBytes == null) {
      _snack('Unggah foto KTP dulu, ya.', error: true);
      return;
    }
    if (_selfieBytes == null) {
      _snack('Unggah foto selfie dulu, ya.', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = await ref.read(kycControllerProvider.notifier).submit(
          fullName: _nameC.text,
          idNumber: _nikC.text,
          idPhotoBytes: _idBytes!,
          idPhotoExt: _idExt,
          selfieBytes: _selfieBytes!,
          selfieExt: _selfieExt,
        );
    if (!mounted) return;
    if (ok) {
      _snack('Pengajuan KYC terkirim. Tunggu verifikasi admin, ya.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appAuthProvider).profile;

    ref.listen<AsyncValue<void>>(kycControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        _snack(e is AppException ? e.message : 'Terjadi kesalahan.',
            error: true);
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Identitas (KYC)')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : _buildForState(profile),
    );
  }

  Widget _buildForState(UserProfile profile) {
    if (profile.kycVerified) {
      return const _StatusView(
        icon: Icons.verified_user_outlined,
        color: AppColors.success,
        title: 'Identitas Terverifikasi',
        message:
            'Akunmu sudah terverifikasi. Terima kasih sudah melengkapi KYC!',
      );
    }
    if (profile.kycPending) {
      return const _StatusView(
        icon: Icons.hourglass_top_outlined,
        color: AppColors.warning,
        title: 'Menunggu Verifikasi',
        message:
            'Pengajuan KYC kamu sedang ditinjau admin. Kami akan memberi tahu '
            'begitu ada hasilnya.',
      );
    }
    _prefill(profile);
    return _buildForm(profile);
  }

  Widget _buildForm(UserProfile profile) {
    final busy = ref.watch(kycControllerProvider).isLoading;
    final rejected =
        profile.kycRejected && (profile.kycRejectReason?.isNotEmpty ?? false);
    return AbsorbPointer(
      absorbing: busy,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (rejected)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pengajuan sebelumnya ditolak',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error)),
                          const SizedBox(height: 2),
                          Text(profile.kycRejectReason!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Text('Lengkapi data identitasmu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'Verifikasi identitas (KYC) meningkatkan kepercayaan & keamanan '
              'transaksi. Data hanya dipakai untuk verifikasi.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _label('Nama sesuai KTP'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameC,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Nama lengkap'),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Nama minimal 3 karakter'
                  : null,
            ),
            const SizedBox(height: 16),
            _label('Nomor KTP (NIK)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nikC,
              keyboardType: TextInputType.number,
              maxLength: 16,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '16 digit NIK',
                counterText: '',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (!RegExp(r'^\d{16}$').hasMatch(s)) {
                  return 'NIK harus 16 digit angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _label('Foto KTP'),
            const SizedBox(height: 8),
            _DocPicker(
              bytes: _idBytes,
              hint: 'Unggah foto KTP yang jelas & tidak buram',
              icon: Icons.badge_outlined,
              onTap: () => _pick(isSelfie: false),
            ),
            const SizedBox(height: 16),
            _label('Foto Selfie dengan KTP'),
            const SizedBox(height: 8),
            _DocPicker(
              bytes: _selfieBytes,
              hint: 'Selfie sambil memegang KTP',
              icon: Icons.account_box_outlined,
              onTap: () => _pick(isSelfie: true),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: busy ? null : _submit,
              icon: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.send_outlined),
              label: Text(busy ? 'Mengirim...' : 'Kirim Pengajuan'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dengan mengirim, kamu menyatakan data yang diberikan benar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
}

/// Kotak unggah dokumen: tampilkan placeholder atau preview foto terpilih.
class _DocPicker extends StatelessWidget {
  final Uint8List? bytes;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  const _DocPicker({
    required this.bytes,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: bytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(bytes!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Ganti',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(hint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 13)),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  const _StatusView({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: color),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }
}