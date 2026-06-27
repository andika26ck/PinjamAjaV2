import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/item.dart';

// Auth (Fase 1)
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

// Home & Search (Fase 2)
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/search_screen.dart';

// Items (Fase 3)
import '../../features/items/presentation/screens/item_detail_screen.dart';
import '../../features/items/presentation/screens/owner_items_screen.dart';
import '../../features/items/presentation/screens/add_edit_item_screen.dart';

// Booking (Fase 4)
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/my_bookings_screen.dart';
import '../../features/booking/presentation/screens/owner_bookings_screen.dart';
import '../../features/booking/presentation/screens/booking_detail_screen.dart';

// Chat (Fase 5)
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

// Profile (Fase 6/7)
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart'; // (+) wishlist

import '../widgets/placeholder_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  // Jembatani state auth ke Listenable agar GoRouter re-evaluasi redirect.
  final authNotifier = ValueNotifier<AppAuthState>(ref.read(appAuthProvider));
  ref.listen<AppAuthState>(
    appAuthProvider,
    (_, next) => authNotifier.value = next,
  );
  ref.onDispose(authNotifier.dispose);

  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = authNotifier.value;
      final loc = state.matchedLocation;
      const publicRoutes = {
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
      };
      final onSplash = loc == AppRoutes.splash;

      switch (auth.status) {
        case AuthStatus.loading:
          return onSplash ? null : AppRoutes.splash;
        case AuthStatus.unauthenticated:
          if (publicRoutes.contains(loc)) return null;
          return AppRoutes.onboarding;
        case AuthStatus.authenticated:
          if (!auth.hasRole) {
            return loc == AppRoutes.roleSelection
                ? null
                : AppRoutes.roleSelection;
          }
          if (onSplash ||
              publicRoutes.contains(loc) ||
              loc == AppRoutes.roleSelection) {
            return AppRoutes.home;
          }
          return null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        name: 'roleSelection',
        builder: (_, __) => const RoleSelectionScreen(),
      ),

      // Bottom navigation shell (Home, Chat, Notif, Profile)
      ShellRoute(
        navigatorKey: shellKey,
        builder: (_, __, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.chat,
            name: 'chat',
            builder: (_, __) => const ChatListScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            builder: (_, __) => const PlaceholderScreen(
              title: 'Notifikasi',
              icon: Icons.notifications_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Full-screen routes (tanpa bottom nav)
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.itemDetail,
        name: 'itemDetail',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            ItemDetailScreen(itemId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.ownerItems,
        name: 'ownerItems',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const OwnerItemsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerItemAdd,
        name: 'ownerItemAdd',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AddEditItemScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerItemEdit,
        name: 'ownerItemEdit',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            AddEditItemScreen(itemId: s.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.booking,
        name: 'booking',
        parentNavigatorKey: rootKey,
        builder: (_, s) => BookingScreen(
          itemId: s.pathParameters['id']!,
          item: s.extra is Item ? s.extra as Item : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingPayment,
        name: 'bookingPayment',
        parentNavigatorKey: rootKey,
        builder: (_, s) => PlaceholderScreen(
            title: 'Pembayaran #${s.pathParameters['id']}'),
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        name: 'myBookings',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerBookings,
        name: 'ownerBookings',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const OwnerBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        name: 'bookingDetail',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            BookingDetailScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        name: 'chatRoom',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            ChatScreen(bookingId: s.pathParameters['bookingId']!),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profileEdit',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.publicProfile,
        name: 'publicProfile',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            PublicProfileScreen(userId: s.pathParameters['id']!),
      ),

      // Wishlist / Favorit (Fase 8) // (+) wishlist
      GoRoute( // (+) wishlist
        path: AppRoutes.wishlist, // '/wishlist'
        name: 'wishlist',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const WishlistScreen(),
      ),
    ],
  );
}