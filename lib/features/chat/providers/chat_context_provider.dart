import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/providers/booking_provider.dart';

part 'chat_context_provider.g.dart';

/// Konteks satu ruang chat: item, lawan bicara, dan booking (opsional).
class ChatContext {
  final Item? item;
  final UserProfile? otherUser;
  final Booking? booking; // null bila belum ada booking (chat pra-booking)
  final String myId;
  final String itemId;
  final String otherUserId;

  const ChatContext({
    required this.item,
    required this.otherUser,
    required this.booking,
    required this.myId,
    required this.itemId,
    required this.otherUserId,
  });
}

/// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
/// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
@riverpod
Future<ChatContext> chatContext(
  ChatContextRef ref,
  String itemId,
  String otherUserId,
) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';

  final results = await Future.wait([
    _safeItem(repo, itemId),
    repo.fetchProfile(otherUserId),
    _safeLatestBooking(repo, itemId: itemId, userA: myId, userB: otherUserId),
  ]);

  return ChatContext(
    item: results[0] as Item?,
    otherUser: results[1] as UserProfile?,
    booking: results[2] as Booking?,
    myId: myId,
    itemId: itemId,
    otherUserId: otherUserId,
  );
}

/// Target chat (item + lawan bicara) yang diturunkan dari sebuah booking.
/// Dipakai entry-point lama (notifikasi / deep link berbasis bookingId).
class ChatTarget {
  final String itemId;
  final String otherUserId;
  const ChatTarget({required this.itemId, required this.otherUserId});
}

@riverpod
Future<ChatTarget> chatTargetFromBooking(
  ChatTargetFromBookingRef ref,
  String bookingId,
) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
  final booking = await repo.fetchBookingById(bookingId);
  final otherUserId =
      booking.renterId == myId ? booking.ownerId : booking.renterId;
  return ChatTarget(itemId: booking.itemId, otherUserId: otherUserId);
}

Future<Item?> _safeItem(dynamic repo, String itemId) async {
  try {
    return await repo.fetchItem(itemId) as Item;
  } catch (_) {
    return null;
  }
}

Future<Booking?> _safeLatestBooking(
  dynamic repo, {
  required String itemId,
  required String userA,
  required String userB,
}) async {
  try {
    return await repo.fetchLatestBookingBetween(
      itemId: itemId,
      userA: userA,
      userB: userB,
    ) as Booking?;
  } catch (_) {
    return null;
  }
}