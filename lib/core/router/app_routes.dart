/// Definisi path & nama route terpusat (typed helpers).
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';

  static const home = '/home';
  static const search = '/home/search';
  static const itemDetail = '/home/item/:id';

  static const ownerItems = '/owner/items';
  static const ownerItemAdd = '/owner/items/add';
  static const ownerItemEdit = '/owner/items/:id/edit';

  static const booking = '/booking/:id';
  static const bookingPayment = '/booking/:id/payment';

  static const chat = '/chat';
  static const chatRoom = '/chat/:bookingId';

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  static const notifications = '/notifications';

  // Booking (Fase 4)
  static const myBookings = '/bookings';
  static const ownerBookings = '/owner/bookings';
  static const bookingDetail = '/bookings/:id';

  // Profil publik (Fase 7)
  static const publicProfile = '/user/:id';

  // Wishlist / Favorit (Fase 8) // (+) wishlist
  static const wishlist = '/wishlist'; // (+) wishlist

  // Helpers untuk membangun path dengan parameter.
  static String itemDetailPath(String id) => '/home/item/$id';
  static String ownerItemEditPath(String id) => '/owner/items/$id/edit';
  static String bookingPath(String id) => '/booking/$id';
  static String bookingPaymentPath(String id) => '/booking/$id/payment';
  static String chatRoomPath(String bookingId) => '/chat/$bookingId';
  static String bookingDetailPath(String id) => '/bookings/$id';
  static String publicProfilePath(String userId) => '/user/$userId';
}