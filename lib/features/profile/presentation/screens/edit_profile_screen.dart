import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../data/models/user_profile.dart';
import '../../providers/profile_provider.dart';

/// Validasi nomor HP Indonesia: terima 08xx, 62xx, atau +62xx.
String? validatePhoneId(String? v) {
  final raw = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
  if (raw.isEmpty) return 'Nomor HP wajib diisi';
  final reg = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,11}$');
  if (!reg.hasMatch(raw)) {
    return 'Format tidak valid (contoh: 0812xxxxxxx atau +62812xxxxxxx)';
  }
  return null;
}

/// Normalisasi ke format +62 sebelum disimpan.
String normalizePhoneId(String input) {
  var s = input.replaceAll(RegExp(r'[\s-]'), '');
  if (s.startsWith('+62')) return s;
  if (s.startsWith('62')) return '+$s';
  if (s.startsWith('0')) return '+62${s.substring(1)}';
  return s;
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  UserRole? _role;

  Uint8List? _newAvatarBytes;
  String _newAvatarExt = 'jpg';
  bool _initialized = false;

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  void _initFrom(UserProfile? p) {
    if (_initialized || p == null) return;
    _nameC.text = p.name ?? '';
    _phoneC.text = p.phone ?? '';
    _role = p.role;
    _initialized = true;
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _newAvatarBytes = bytes;
        _newAvatarExt =
            picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal memilih foto.'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final notifier = ref.read(profileControllerProvider.notifier);

    // 1) Upload foto baru bila ada (dikompres di dalam controller).
    if (_newAvatarBytes != null) {
      final okAvatar =
          await notifier.uploadAvatar(_newAvatarBytes!, _newAvatarExt);
      if (!okAvatar) return; // error sudah ditangani via listener
    }

    // 2) Simpan data teks + peran (nomor HP dinormalisasi ke +62).
    final ok = await notifier.updateProfile(
      name: _nameC.text.trim(),
      phone: normalizePhoneId(_phoneC.text),
      role: _role,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider);
    _initFrom(profile);

    ref.listen<AsyncValue<void>>(profileControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e is AppException ? e.message : 'Terjadi kesalahan.'),
          backgroundColor: AppColors.error,
        ));
      });
    });

    final busy = ref.watch(profileControllerProvider).isLoading;
    final currentAvatar = profile?.avatarUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.surfaceVariant,
                            backgroundImage: _newAvatarBytes != null
                                ? MemoryImage(_newAvatarBytes!)
                                : ((currentAvatar != null &&
                                        currentAvatar.isNotEmpty)
                                    ? CachedNetworkImageProvider(currentAvatar)
                                    : null) as ImageProvider?,
                            child: (_newAvatarBytes == null &&
                                    (currentAvatar == null ||
                                        currentAvatar.isEmpty))
                                ? Text(
                                    (profile.name ?? '?')
                                        .characters
                                        .first
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: busy ? null : _pickAvatar,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: busy ? null : _pickAvatar,
                        child: const Text('Ganti Foto'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nama Lengkap',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameC,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Nama kamu',
                      ),
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Nama minimal 3 karakter'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Nomor HP',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '0812xxxxxxx atau +62812xxxxxxx',
                      ),
                      validator: validatePhoneId,
                    ),
                    const SizedBox(height: 16),
                    const Text('Peran',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<UserRole>(
                      segments: [
                        for (final r in UserRole.values)
                          ButtonSegment(value: r, label: Text(r.label)),
                      ],
                      selected: {_role ?? UserRole.renter},
                      showSelectedIcon: false,
                      onSelectionChanged: busy
                          ? null
                          : (s) => setState(() => _role = s.first),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: busy ? null : _save,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      child: busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}