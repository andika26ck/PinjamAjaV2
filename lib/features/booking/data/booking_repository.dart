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

  /// Booking terakhir antara dua user pada satu item (untuk konteks chat).
  /// Mengembalikan null bila belum ada booking di antara mereka.
  Future<Booking?> fetchLatestBookingBetween({
    required String itemId,
    required String userA,
    required String userB,
  });

  /// Stream real-time booking milik penyewa / pemilik.
  Stream<List<Booking>> watchRenterBookings(String renterId);
  Stream<List<Booking>> watchOwnerBookings(String ownerId);

  /// Lengkapi daftar booking dengan info item (1 query batch).
  Future<List<BookingView>> attachItems(List<Booking> bookings);

  Future<Booking> updateStatus({
    required String id,
    required String status,
    String? cancellationReason,
    String? refundStatus,
  });
  Future<Booking> markPaid(String id);

  /// Owner mengonfirmasi booking secara eksklusif (atomic di server):
  /// memastikan tak ada bentrok terkonfirmasi, lalu auto-batalkan +
  /// refund booking lain yang bentrok pada tanggal yang sama.
  Future<Booking> confirmBooking(String id);

  /// Owner mulai sewa -> active + catat started_at.
  Future<Booking> markStarted(String id);

  /// Owner tandai dikembalikan -> completed + simpan denda keterlambatan.
  Future<Booking> markReturned({
    required String id,
    required DateTime returnedAt,
    required int lateDays,
    required int lateFee,
    required int depositRefund,
    required String lateFeeStatus,
  });

  /// Penyewa membayar kekurangan denda (simulasi).
  Future<Booking> payLateFee(String id);

  Future<bool> hasReview({
    required String bookingId,
    required String reviewerId,
  });
  Future<void> submitReview(Map<String, dynamic> payload);
}