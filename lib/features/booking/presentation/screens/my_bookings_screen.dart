import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../data/booking_repository.dart';
import '../../providers/booking_list_provider.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  static const _tabs = <(String, Set<String>)>[
    ('Menunggu', {'pending', 'confirmed'}),
    ('Aktif', {'active'}),
    ('Selesai', {'completed'}),
    ('Dibatalkan', {'cancelled'}),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(renterBookingsProvider);
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Saya'),
          bottom: TabBar(
            isScrollable: true,
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
                _BookingList(
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

class _BookingList extends StatelessWidget {
  final List<BookingView> views;
  const _BookingList({required this.views});

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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final v = views[i];
        return BookingCard(
          view: v,
          onTap: () => context.push(AppRoutes.bookingDetailPath(v.booking.id)),
        );
      },
    );
  }
}