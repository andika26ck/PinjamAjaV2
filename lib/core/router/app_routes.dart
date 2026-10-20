/// Definisi path & nama route terpusat (typed helpers).
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';
  static const security = '/security';
  static const changePassword = '/change-password';
  static const resetPassword = '/reset-password';

  static const home = '/home';
  static const search = '/home/search';
  static const itemDetail = '/home/item/:id';

  static const ownerItems = '/owner/items';
  static const ownerItemAdd = '/owner/items/add';
  static const ownerItemEdit = '/owner/items/:id/edit';

  static const booking = '/booking/:id';
  static const bookingPayment = '/booking/:id/payment';

  static const chat = '/chat';
  static const chatRoom = '/chat/item/:itemId/:otherUserId';
  static const chatRoomByBooking = '/chat/booking/:bookingId';

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const kycSubmission = '/profile/kyc'; // (+) KYC (Pelengkap user)

  static const notifications = '/notifications';

  // Booking (Fase 4)
  static const myBookings = '/bookings';
  static const ownerBookings = '/owner/bookings';
  static const bookingDetail = '/bookings/:id';
  static const disputeSubmission = '/bookings/:id/dispute'; // (+) Sengketa (Pelengkap user)

  // Profil publik (Fase 7)
  static const publicProfile = '/user/:id';

  // Wishlist / Favorit (Fase 8) // (+) wishlist
  static const wishlist = '/wishlist'; // (+) wishlist

  // Payment (Fase 9)
  static const paymentWebview = '/booking/:id/payment/webview';
  static const paymentSuccess = '/booking/:id/payment/success';
  static const paymentPending = '/booking/:id/payment/pending';
  static const paymentFailed = '/booking/:id/payment/failed';
  static const ownerEarnings = '/owner/earnings';

  // Rekening pencairan pemilik (payout manual)
  static const ownerPayoutAccount = '/owner/payout-account';

  // Bayar Manual (QRIS + Transfer, verifikasi admin)
  static const bookingManualPayment = '/booking/:id/manual-payment';

  // Helpers untuk membangun path dengan parameter.
  static String itemDetailPath(String id) => '/home/item/$id';
  static String ownerItemEditPath(String id) => '/owner/items/$id/edit';
  static String bookingPath(String id) => '/booking/$id';
  static String bookingPaymentPath(String id) => '/booking/$id/payment';
  static String chatRoomPath(String itemId, String otherUserId) =>
      '/chat/item/$itemId/$otherUserId';
  static String chatRoomByBookingPath(String bookingId) =>
      '/chat/booking/$bookingId';
  static String bookingDetailPath(String id) => '/bookings/$id';
  static String disputeSubmissionPath(String id) => '/bookings/$id/dispute';
  static String publicProfilePath(String userId) => '/user/$userId';

  // Payment helpers (Fase 9)
  static String paymentPath(String id) => '/booking/$id/payment';
  static String paymentWebviewPath(String id) => '/booking/$id/payment/webview';
  static String paymentSuccessPath(String id) => '/booking/$id/payment/success';
  static String paymentPendingPath(String id) => '/booking/$id/payment/pending';
  static String paymentFailedPath(String id) => '/booking/$id/payment/failed';
  static String bookingManualPaymentPath(String id) =>
      '/booking/$id/manual-payment';

  // Admin (Fase 3+)
  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminKyc = '/admin/kyc';
  static const adminModeration = '/admin/moderation';
  static const adminReports = '/admin/reports';
  static const adminDisputes = '/admin/disputes';
  static const adminPayouts = '/admin/payouts';
  static const adminConfig = '/admin/config';
  static const adminManualPayments = '/admin/manual-payments';
  static const adminManualPayouts = '/admin/manual-payouts';
  static const adminManualRefunds = '/admin/manual-refunds';

  // Akun dibekukan (Fase 3)
  static const suspended = '/suspended';
}