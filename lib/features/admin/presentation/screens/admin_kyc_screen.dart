import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_profile.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminKycScreen extends ConsumerWidget {
  const AdminKycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(adminKycQueueProvider);
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.kyc,
      title: 'Verifikasi KYC',
      body: Column(
        children: [
          if (isWorking) const LinearProgressIndicator(),
          Expanded(
            child: queueAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _kycError(ref, '$e'),
              data: (users) {
                if (users.isEmpty) return _emptyQueue();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminKycQueueProvider);
                    await ref.read(adminKycQueueProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) => _KycCard(
                      user: users[i],
                      onReview: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _KycReviewScreen(user: users[i]),
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
}

Widget _emptyQueue() => ListView(
      children: const [
        SizedBox(height: 80),
        Icon(Icons.verified_user_outlined,
            size: 56, color: AppColors.success),
        SizedBox(height: 12),
        Text('Tidak ada antrian KYC 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text('Semua pengajuan verifikasi sudah ditinjau.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    );

Widget _kycError(WidgetRef ref, String message) => ListView(
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
            onPressed: () => ref.invalidate(adminKycQueueProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ),
      ],
    );

class _KycCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onReview;
  const _KycCard({required this.user, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage:
                    hasAvatar ? NetworkImage(user.avatarUrl!) : null,
                child: hasAvatar
                    ? null
                    : const Icon(Icons.person,
                        color: AppColors.textTertiary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.kycFullName?.isNotEmpty == true
                          ? user.kycFullName!
                          : (user.name ?? '(Tanpa nama)'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (user.kycIdNumber != null &&
                        user.kycIdNumber!.isNotEmpty)
                      Text('No. ID: ${user.kycIdNumber}',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                  ],
                ),
              ),
              const _Badge('Menunggu', AppColors.secondary),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onReview,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Tinjau'),
            ),
          ),
        ],
      ),
    );
  }
}

class _KycReviewScreen extends ConsumerWidget {
  final UserProfile user;
  const _KycReviewScreen({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWorking = ref.watch(adminControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Tinjau KYC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Nama lengkap (KTP)', user.kycFullName),
          _field('Nomor identitas', user.kycIdNumber),
          _field('Diajukan', user.kycSubmittedAt?.toLocal().toString()),
          const SizedBox(height: 16),
          const Text('Foto Identitas',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _photo(context, user.kycIdPhotoUrl),
          const SizedBox(height: 16),
          const Text('Foto Selfie',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _photo(context, user.kycSelfieUrl),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      isWorking ? null : () => _reject(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      isWorking ? null : () => _approve(context, ref),
                  icon: const Icon(Icons.check),
                  label: const Text('Setujui'),
                ),
              ),
            ],
          ),
          if (isWorking) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
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

  Widget _photo(BuildContext context, String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Tidak ada foto',
              style: TextStyle(color: AppColors.textTertiary)),
        ),
      );
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _PhotoViewer(url: url),
      )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (c, child, progress) => progress == null
              ? child
              : Container(
                  height: 200,
                  color: AppColors.surfaceVariant,
                  child:
                      const Center(child: CircularProgressIndicator()),
                ),
          errorBuilder: (c, e, s) => Container(
            height: 200,
            color: AppColors.surfaceVariant,
            child: const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: AppColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(adminControllerProvider.notifier)
        .reviewKyc(userId: user.id, approve: true);
    _finish(context, ref, ok, 'KYC ${user.name ?? ''} disetujui.');
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Tolak KYC'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Alasan penolakan…',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
    if (reason == null) return;
    final ok = await ref.read(adminControllerProvider.notifier).reviewKyc(
          userId: user.id,
          approve: false,
          rejectReason: reason.isEmpty ? null : reason,
        );
    _finish(context, ref, ok, 'KYC ${user.name ?? ''} ditolak.');
  }

  void _finish(BuildContext context, WidgetRef ref, bool ok, String msg) {
    final err = ref.read(adminControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? msg : 'Gagal: ${err ?? 'terjadi kesalahan'}'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
    if (ok && context.mounted) Navigator.of(context).pop();
  }
}

class _PhotoViewer extends StatelessWidget {
  final String url;
  const _PhotoViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(url),
        ),
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