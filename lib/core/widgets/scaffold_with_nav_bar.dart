import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_profile.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/chat/providers/chat_unread_count_provider.dart';
import '../../features/notification/providers/unread_count_provider.dart';
import '../router/app_routes.dart';

/// Scaffold pembungkus untuk ShellRoute dengan bottom navigation.
/// Menampilkan badge unread pada tab Chat & Notifikasi (update realtime).
class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  int _indexFromLocation(String location, List<String> tabs) {
    final i = tabs.indexWhere(
      (t) => location == t || location.startsWith('$t/'),
    );
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    // Tab "Booking" menyesuaikan peran: penyewa -> /bookings,
    // pemilik -> /owner/bookings.
    final isOwner =
        ref.watch(appAuthProvider).profile?.role == UserRole.owner;
    final bookingRoute =
        isOwner ? AppRoutes.ownerBookings : AppRoutes.myBookings;

    final tabs = <String>[
      AppRoutes.home,
      bookingRoute,
      AppRoutes.chat,
      AppRoutes.notifications,
      AppRoutes.profile,
    ];
    final index = _indexFromLocation(location, tabs);

    final chatUnread = ref.watch(chatUnreadCountProvider);
    final notifUnread = ref.watch(notificationUnreadCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.go(tabs[i]),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: _NavBadge(
                icon: Icons.chat_bubble_outline, count: chatUnread),
            activeIcon:
                _NavBadge(icon: Icons.chat_bubble, count: chatUnread),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _NavBadge(
                icon: Icons.notifications_outlined, count: notifUnread),
            activeIcon:
                _NavBadge(icon: Icons.notifications, count: notifUnread),
            label: 'Notifikasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Ikon bottom-nav dengan badge angka unread (otomatis sembunyi bila 0).
class _NavBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  const _NavBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(icon),
    );
  }
}