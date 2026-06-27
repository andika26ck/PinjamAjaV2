import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';

/// Gabungan booking + ringkasan item untuk kartu daftar.
class BookingView {
  final Booking booking;
  final Item? item;
  const BookingView({required this.booking, this.item});
}

/// Kontrak repository untuk fitur booking.
abstract class BookingRepository {
  Future<Booking> createBooking(Map<String, dynamic> payload);
  Future<Booking> fetchBookingById(String id);
  Future<Item> fetchItem(String itemId);
  Future<UserProfile?> fetchProfile(String userId);
  Future<List<Booking>> fetchItemBookings(String itemId);

  /// Stream real-time booking milik penyewa / pemilik.
  Stream<List<Booking>> watchRenterBookings(String renterId);
  Stream<List<Booking>> watchOwnerBookings(String ownerId);

  /// Lengkapi daftar booking dengan info item (1 query batch).
  Future<List<BookingView>> attachItems(List<Booking> bookings);

  Future<Booking> updateStatus({
    required String id,
    required String status,
    String? cancellationReason,
  });
  Future<Booking> markPaid(String id);

  Future<bool> hasReview({
    required String bookingId,
    required String reviewerId,
  });
  Future<void> submitReview(Map<String, dynamic> payload);
}