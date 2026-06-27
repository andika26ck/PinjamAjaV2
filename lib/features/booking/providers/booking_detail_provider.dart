import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import 'booking_provider.dart';

part 'booking_detail_provider.g.dart';

/// Data lengkap untuk layar detail booking.
class BookingDetailBundle {
  final Booking booking;
  final Item? item;
  final UserProfile? renter;
  final UserProfile? owner;
  final bool hasReview;
  final bool isOwner;

  const BookingDetailBundle({
    required this.booking,
    this.item,
    this.renter,
    this.owner,
    this.hasReview = false,
    this.isOwner = false,
  });
}

@riverpod
Future<BookingDetailBundle> bookingDetail(
    BookingDetailRef ref, String bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;

  final booking = await repo.fetchBookingById(bookingId);
  final profiles = await Future.wait([
    repo.fetchProfile(booking.renterId),
    repo.fetchProfile(booking.ownerId),
  ]);

  Item? item;
  try {
    item = await repo.fetchItem(booking.itemId);
  } catch (_) {
    item = null; // item mungkin sudah dihapus
  }

  var hasReview = false;
  if (uid != null && booking.status == AppConstantsCompleted) {
    hasReview = await repo.hasReview(bookingId: bookingId, reviewerId: uid);
  }

  return BookingDetailBundle(
    booking: booking,
    item: item,
    renter: profiles[0] as UserProfile?,
    owner: profiles[1] as UserProfile?,
    hasReview: hasReview,
    isOwner: uid != null && uid == booking.ownerId,
  );
}

// Konstanta lokal agar tak perlu import AppConstants hanya untuk satu nilai.
const AppConstantsCompleted = 'completed';