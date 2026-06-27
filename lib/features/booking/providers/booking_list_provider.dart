import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/booking_repository.dart';
import 'booking_provider.dart';

part 'booking_list_provider.g.dart';

/// Stream booking milik penyewa (real-time) + info item.
@riverpod
Stream<List<BookingView>> renterBookings(RenterBookingsRef ref) async* {
  final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (uid == null) {
    yield const [];
    return;
  }
  final repo = ref.watch(bookingRepositoryProvider);
  await for (final bookings in repo.watchRenterBookings(uid)) {
    yield await repo.attachItems(bookings);
  }
}

/// Stream booking pada barang milik owner (real-time) + info item.
@riverpod
Stream<List<BookingView>> ownerBookings(OwnerBookingsRef ref) async* {
  final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (uid == null) {
    yield const [];
    return;
  }
  final repo = ref.watch(bookingRepositoryProvider);
  await for (final bookings in repo.watchOwnerBookings(uid)) {
    yield await repo.attachItems(bookings);
  }
}