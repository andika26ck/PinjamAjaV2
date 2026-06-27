import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../data/booking_repository.dart';
import '../../providers/booking_list_provider.dart';
import '../../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  static const _tabs = <(String, Set<String>)>[
    ('Permintaan Masuk', {'pending'}),
    ('Aktif', {'confirmed', 'active'}),
    ('Selesai', {'completed', 'cancelled'}),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownerBookingsProvider);
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Masuk'),
          bottom: TabBar(
            tabs: [for (final t in _tabs) Tab(text: t.$1)],
          ),
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
                e is AppException ? e.message : 'Gagal memuat booking.'),
          ),
          data: (views) => TabBarView(
            children: [
              for (final t in _tabs)
                _OwnerList(
                  views: views
                      .where((v) => t.$2.contains(v.booking.status))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerList extends StatelessWidget {
  final List<BookingView> views;
  const _OwnerList({required this.views});

  @override
  Widget build(BuildContext context) {
    if (views.isEmpty) {
      return const Center(
        child: Text('Belum ada booking di sini.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: views.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _OwnerBookingTile(view: views[i]),
    );
  }
}

class _OwnerBookingTile extends ConsumerWidget {
  final BookingView view;
  const _OwnerBookingTile({required this.view});

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await _askReason(context);
    if (reason == null) return;
    await ref
        .read(bookingControllerProvider.notifier)
        .rejectBooking(view.booking.id, reason: reason);
  }

  Future<String?> _askReason(BuildContext context) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Booking'),
        content: TextField(
          controller: c,
          maxLines: 2,
          decoration:
              const InputDecoration(hintText: 'Alasan penolakan (opsional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(
                ctx,
                c.text.trim().isEmpty
                    ? 'Ditolak oleh pemilik'
                    : c.text.trim()),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = view.booking.status;
    final busy = ref.watch(bookingControllerProvider).isLoading;
    final notifier = ref.read(bookingControllerProvider.notifier);

    final actions = <Widget>[];
    if (status == 'pending') {
      actions.addAll([
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error),
            onPressed: busy ? null : () => _reject(context, ref),
            child: const Text('Tolak'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed:
                busy ? null : () => notifier.confirmBooking(view.booking.id),
            child: const Text('Terima'),
          ),
        ),
      ]);
    } else if (status == 'confirmed') {
      actions.add(Expanded(
        child: ElevatedButton(
          onPressed:
              busy ? null : () => notifier.startRental(view.booking.id),
          child: const Text('Mulai Sewa'),
        ),
      ));
    } else if (status == 'active') {
      actions.add(Expanded(
        child: ElevatedButton(
          onPressed:
              busy ? null : () => notifier.markReturned(view.booking.id),
          child: const Text('Tandai Dikembalikan'),
        ),
      ));
    }

    return Column(
      children: [
        BookingCard(
          view: view,
          onTap: () =>
              context.push(AppRoutes.bookingDetailPath(view.booking.id)),
        ),
        if (actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: actions),
          ),
      ],
    );
  }
}