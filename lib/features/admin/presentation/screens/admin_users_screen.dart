import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_profile.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _suspendedOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(
      query: _query.isEmpty ? null : _query,
      suspendedOnly: _suspendedOnly ? true : null,
    ));
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.users,
      title: 'Manajemen Pengguna',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau nomor HP…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (v) => setState(() => _query = v.trim()),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Hanya yang dibekukan'),
                    selected: _suspendedOnly,
                    onSelected: (v) => setState(() => _suspendedOnly = v),
                  ),
                ),
              ],
            ),
          ),
          if (isWorking) const LinearProgressIndicator(),
          Expanded(
            child: usersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(adminUsersProvider),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada pengguna ditemukan.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminUsersProvider);
                    await ref.read(adminUsersProvider(
                      query: _query.isEmpty ? null : _query,
                      suspendedOnly: _suspendedOnly ? true : null,
                    ).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _UserTile(
                      user: users[i],
                      onTap: () => _openActions(users[i]),
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

  void _openActions(UserProfile user) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _UserActionsSheet(
        user: user,
        onToggleSuspend: () => _toggleSuspend(user),
      ),
    );
  }

  Future<void> _toggleSuspend(UserProfile user) async {
    Navigator.pop(context); // tutup sheet
    if (user.isSuspended) {
      final ok = await ref
          .read(adminControllerProvider.notifier)
          .setSuspended(userId: user.id, suspended: false);
      _showResult(ok, 'Akun ${user.name ?? ''} diaktifkan kembali.');
    } else {
      final reason = await _askReason();
      if (reason == null) return; // batal
      final ok = await ref
          .read(adminControllerProvider.notifier)
          .setSuspended(
            userId: user.id,
            suspended: true,
            reason: reason.isEmpty ? null : reason,
          );
      _showResult(ok, 'Akun ${user.name ?? ''} dibekukan.');
    }
  }

  Future<String?> _askReason() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bekukan Akun'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Alasan pembekuan (opsional)…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Bekukan'),
          ),
        ],
      ),
    );
  }

  void _showResult(bool ok, String successMsg) {
    if (!mounted) return;
    final err = ref.read(adminControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(ok ? successMsg : 'Gagal: ${err ?? 'terjadi kesalahan'}'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }
}

String _kycLabel(String status) => switch (status) {
      'verified' => 'KYC ✓',
      'pending' => 'KYC menunggu',
      'rejected' => 'KYC ditolak',
      _ => 'Belum KYC',
    };

Color _kycColor(String status) => switch (status) {
      'verified' => AppColors.success,
      'pending' => AppColors.secondary,
      'rejected' => AppColors.error,
      _ => AppColors.textTertiary,
    };

class _UserTile extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;
  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
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
                      user.name?.isNotEmpty == true
                          ? user.name!
                          : '(Tanpa nama)',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (user.phone != null && user.phone!.isNotEmpty)
                      Text(user.phone!,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (user.isAdmin)
                          const _Badge('Admin', AppColors.primary),
                        if (user.isSuspended)
                          const _Badge('Dibekukan', AppColors.error),
                        _Badge(_kycLabel(user.kycStatus),
                            _kycColor(user.kycStatus)),
                        if (user.role != null)
                          _Badge(user.role!.label,
                              AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserActionsSheet extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onToggleSuspend;
  const _UserActionsSheet({
    required this.user,
    required this.onToggleSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(user.name ?? '(Tanpa nama)'),
            subtitle: Text(user.phone ?? '—'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              user.isSuspended ? Icons.lock_open : Icons.block,
              color:
                  user.isSuspended ? AppColors.success : AppColors.error,
            ),
            title: Text(user.isSuspended
                ? 'Aktifkan kembali akun'
                : 'Bekukan akun'),
            subtitle: user.isSuspended && user.suspendedReason != null
                ? Text('Alasan: ${user.suspendedReason}')
                : null,
            onTap: onToggleSuspend,
          ),
          const SizedBox(height: 8),
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