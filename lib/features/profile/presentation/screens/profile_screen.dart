import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../data/models/user_profile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/profile_repository.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final email = ref.watch(supabaseClientProvider).auth.currentUser?.email;
    final isOwner = profile?.role == UserRole.owner;

    ref.listen<AsyncValue<void>>(profileControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e is AppException ? e.message : 'Terjadi kesalahan.'),
          backgroundColor: AppColors.error,
        ));
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Edit Profil',
            onPressed: () => context.push(AppRoutes.profileEdit),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _Header(
                  profile: profile,
                  onTapAvatar: () => context.push(AppRoutes.profileEdit),
                ),
                _InfoSection(profile: profile, email: email),
                const SizedBox(height: 8),
                _StatsRow(userId: profile.id),
                const SizedBox(height: 8),

                // ---- Transaksi ----
                const _SectionLabel('Transaksi'),
                if (isOwner)
                  _MenuTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Barang Saya',
                    subtitle: 'Kelola barang yang kamu sewakan',
                    onTap: () => context.push(AppRoutes.ownerItems),
                  )
                else
                  _MenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Riwayat Sewa',
                    subtitle: 'Riwayat & status sewa kamu',
                    onTap: () => context.push(AppRoutes.myBookings),
                  ),
                if (isOwner)
                  _MenuTile(
                    icon: Icons.inbox_outlined,
                    title: 'Booking Masuk',
                    subtitle: 'Permintaan sewa untuk barangmu',
                    onTap: () => context.push(AppRoutes.ownerBookings),
                  ),
                // (+) wishlist: menu Favorit Saya
                _MenuTile(
                  icon: Icons.favorite_border,
                  title: 'Favorit Saya',
                  subtitle: 'Barang yang kamu simpan',
                  onTap: () => context.push(AppRoutes.wishlist),
                ),
                _MenuTile(
                  icon: Icons.payments_outlined,
                  title: 'Metode Pembayaran',
                  subtitle: 'Atur metode pembayaran',
                  onTap: () => _comingSoon(context),
                ),

                // ---- Akun ----
                const _SectionLabel('Akun'),
                _MenuTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  onTap: () => context.push(AppRoutes.profileEdit),
                ),
                _RoleSwitchTile(profile: profile),
                _MenuTile(
                  icon: Icons.lock_outline,
                  title: 'Keamanan',
                  subtitle: 'Ganti kata sandi',
                  onTap: () => _changePassword(context, ref),
                ),

                // ---- Lainnya ----
                const _SectionLabel('Lainnya'),
                _MenuTile(
                  icon: Icons.help_outline,
                  title: 'Bantuan & FAQ',
                  onTap: () => _comingSoon(context),
                ),
                _MenuTile(
                  icon: Icons.info_outline,
                  title: 'Tentang PinjamAja',
                  onTap: () => _showAbout(context),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Segera hadir.')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PinjamAja',
      applicationVersion: 'v1.0.0',
      applicationLegalese: '© 2024 PinjamAja — Sewa barang jadi mudah.',
      children: const [
        SizedBox(height: 12),
        Text(
            'Marketplace sewa-menyewa barang antar pengguna. Temukan, sewa, dan sewakan barang dengan aman.'),
      ],
    );
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Kata Sandi'),
        content: const Text(
            'Kami akan mengirim tautan untuk mengatur ulang kata sandi ke email kamu. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final sent =
          await ref.read(profileControllerProvider.notifier).sendPasswordReset();
      if (sent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan reset kata sandi telah dikirim.')),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(profileControllerProvider.notifier).signOut();
    }
  }
}

class _Header extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTapAvatar;
  const _Header({required this.profile, required this.onTapAvatar});

  @override
  Widget build(BuildContext context) {
    final avatar = profile.avatarUrl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      color: AppColors.surface,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTapAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: (avatar != null && avatar.isNotEmpty)
                      ? CachedNetworkImageProvider(avatar)
                      : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? Text(
                          (profile.name ?? '?').characters.first.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name?.isNotEmpty == true ? profile.name! : 'Pengguna',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.role?.label ?? 'Belum pilih peran',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: 2),
              Text(
                profile.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.swap_horiz_rounded,
                  size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 2),
              Text(
                '${profile.totalTransactions} transaksi',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UserProfile profile;
  final String? email;
  const _InfoSection({required this.profile, this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          _row(Icons.phone_outlined, 'Nomor HP',
              profile.phone?.isNotEmpty == true ? profile.phone! : '-'),
          _row(Icons.email_outlined, 'Email',
              (email != null && email!.isNotEmpty) ? email! : '-'),
          _row(
            profile.isVerified
                ? Icons.verified_outlined
                : Icons.gpp_maybe_outlined,
            'Status',
            profile.isVerified ? 'Terverifikasi' : 'Belum terverifikasi',
            valueColor:
                profile.isVerified ? AppColors.success : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textTertiary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final String userId;
  const _StatsRow({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileStatsProvider(userId));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: async.when(
        loading: () => const SizedBox(
          height: 48,
          child: Center(
              child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5))),
        ),
        error: (_, __) => const SizedBox(
          height: 48,
          child: Center(child: Text('Gagal memuat statistik')),
        ),
        data: (s) => Row(
          children: [
            _stat('${s.completedRentals}', 'Booking Selesai'),
            _divider(),
            _stat('${s.itemsListed}', 'Barang Disewa'),
            _divider(),
            _stat('${s.reviewsReceived}', 'Ulasan Diterima'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary)),
          ],
        ),
      );

  Widget _divider() =>
      Container(width: 1, height: 36, color: AppColors.border);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 38,
        width: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

class _RoleSwitchTile extends ConsumerWidget {
  final UserProfile profile;
  const _RoleSwitchTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = profile.role == UserRole.owner;
    final target = isOwner ? UserRole.renter : UserRole.owner;
    final busy = ref.watch(profileControllerProvider).isLoading;
    return _MenuTile(
      icon: Icons.swap_horizontal_circle_outlined,
      title: 'Beralih ke ${target.label}',
      subtitle: 'Peran saat ini: ${profile.role?.label ?? '-'}',
      onTap: busy
          ? () {}
          : () async {
              final ok = await ref
                  .read(profileControllerProvider.notifier)
                  .switchRole(target);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Beralih ke ${target.label}.')),
                );
              }
            },
    );
  }
}