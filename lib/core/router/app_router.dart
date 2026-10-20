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
import '../../features/auth/presentation/screens/security_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
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
import '../../features/chat/presentation/screens/chat_room_by_booking_screen.dart';

// Profile (Fase 6/7)
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart'; // (+) wishlist

// KYC (Pelengkap sisi user)
import '../../features/kyc/presentation/screens/kyc_submission_screen.dart';

// Sengketa (Pelengkap sisi user)
import '../../features/dispute/presentation/screens/dispute_submission_screen.dart';

// Notification (Fase 5)
import '../../features/notification/presentation/screens/notification_screen.dart';

// Payment (Fase 9)
import '../../features/payment/presentation/screens/payment_summary_screen.dart';
import '../../features/payment/presentation/screens/payment_webview_screen.dart';
import '../../features/payment/presentation/screens/payment_success_screen.dart';
import '../../features/payment/presentation/screens/payment_pending_screen.dart';
import '../../features/payment/presentation/screens/payment_failed_screen.dart';
import '../../features/payment/presentation/screens/owner_earnings_screen.dart';
import '../../features/payment/presentation/screens/manual_payment_screen.dart';
import '../../features/payment/presentation/screens/payout_account_screen.dart';

// Admin (Fase 3+)
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_kyc_screen.dart';
import '../../features/admin/presentation/screens/admin_moderation_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_disputes_screen.dart';
import '../../features/admin/presentation/screens/admin_payouts_screen.dart';
import '../../features/admin/presentation/screens/admin_config_screen.dart';
import '../../features/admin/presentation/screens/admin_manual_payments_screen.dart';
import '../../features/admin/presentation/screens/admin_manual_payouts_screen.dart';
import '../../features/admin/presentation/screens/admin_manual_refunds_screen.dart';
import '../../features/admin/presentation/screens/suspended_screen.dart';

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
          final profile = auth.profile;

          // 1) Akun dibekukan → kunci di layar "suspended".
          if (profile?.isSuspended ?? false) {
            return loc == AppRoutes.suspended ? null : AppRoutes.suspended;
          }
          // Akun normal tidak boleh nyangkut di layar suspended.
          if (loc == AppRoutes.suspended) return AppRoutes.home;

          // 2) Belum pilih peran → role selection.
          if (!auth.hasRole) {
            return loc == AppRoutes.roleSelection
                ? null
                : AppRoutes.roleSelection;
          }

          // 3) Gate admin: hanya admin yang boleh masuk /admin/*.
          if (loc.startsWith('/admin') && !(profile?.isAdmin ?? false)) {
            return AppRoutes.home;
          }

          // 4) Sudah login penuh → jauhkan dari splash/auth/role.
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
            builder: (_, __) => const NotificationScreen(),
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
        builder: (_, s) => AddEditItemScreen(item: s.extra as Item?),
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
        builder: (_, s) =>
            PaymentSummaryScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.paymentWebview,
        name: 'paymentWebview',
        parentNavigatorKey: rootKey,
        builder: (_, s) => PaymentWebViewScreen(
          bookingId: s.pathParameters['id']!,
          snapToken: s.extra as String,
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        name: 'paymentSuccess',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            PaymentSuccessScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.paymentPending,
        name: 'paymentPending',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            PaymentPendingScreen(bookingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.paymentFailed,
        name: 'paymentFailed',
        parentNavigatorKey: rootKey,
        builder: (_, s) => PaymentFailedScreen(
          bookingId: s.pathParameters['id']!,
          reason: s.extra is String ? s.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerEarnings,
        name: 'ownerEarnings',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const OwnerEarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerPayoutAccount,
        name: 'ownerPayoutAccount',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const PayoutAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingManualPayment,
        name: 'bookingManualPayment',
        parentNavigatorKey: rootKey,
        builder: (_, s) =>
            ManualPaymentScreen(bookingId: s.pathParameters['id']!),
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
        path: AppRoutes.disputeSubmission,
        name: 'disputeSubmission',
        parentNavigatorKey: rootKey,
        builder: (_, s) => DisputeSubmissionScreen(
          bookingId: s.pathParameters['id']!,
          againstId: s.extra is String ? s.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        name: 'chatRoom',
        parentNavigatorKey: rootKey,
        builder: (_, s) => ChatScreen(
          itemId: s.pathParameters['itemId']!,
          otherUserId: s.pathParameters['otherUserId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.chatRoomByBooking,
        name: 'chatRoomByBooking',
        parentNavigatorKey: rootKey,
        builder: (_, s) => ChatRoomByBookingScreen(
          bookingId: s.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profileEdit',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.security,
        name: 'security',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const SecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'resetPassword',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycSubmission,
        name: 'kycSubmission',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const KycSubmissionScreen(),
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

      // Admin (Fase 3) — root routes, tanpa bottom nav
      GoRoute(
        path: AppRoutes.suspended,
        name: 'suspended',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const SuspendedScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        name: 'adminUsers',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminKyc,
        name: 'adminKyc',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminKycScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminModeration,
        name: 'adminModeration',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminModerationScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        name: 'adminReports',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDisputes,
        name: 'adminDisputes',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminDisputesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPayouts,
        name: 'adminPayouts',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminPayoutsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminConfig,
        name: 'adminConfig',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminManualPayments,
        name: 'adminManualPayments',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminManualPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminManualPayouts,
        name: 'adminManualPayouts',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminManualPayoutsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminManualRefunds,
        name: 'adminManualRefunds',
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminManualRefundsScreen(),
      ),
    ],
  );
}