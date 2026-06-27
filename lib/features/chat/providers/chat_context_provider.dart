import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/booking.dart';
import '../../../data/models/item.dart';
import '../../../data/models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/providers/booking_provider.dart';

part 'chat_context_provider.g.dart';

/// Konteks satu ruang chat: booking, item, dan lawan bicara.
class ChatContext {
  final Booking booking;
  final Item? item;
  final UserProfile? otherUser;
  final String myId;
  final String otherUserId;

  const ChatContext({
    required this.booking,
    required this.item,
    required this.otherUser,
    required this.myId,
    required this.otherUserId,
  });
}

@riverpod
Future<ChatContext> chatContext(ChatContextRef ref, String bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';

  final booking = await repo.fetchBookingById(bookingId);
  final otherUserId =
      booking.renterId == myId ? booking.ownerId : booking.renterId;

  final results = await Future.wait([
    repo.fetchProfile(otherUserId),
    _safeItem(repo, booking.itemId),
  ]);

  return ChatContext(
    booking: booking,
    item: results[1] as Item?,
    otherUser: results[0] as UserProfile?,
    myId: myId,
    otherUserId: otherUserId,
  );
}

Future<Item?> _safeItem(dynamic repo, String itemId) async {
  try {
    return await repo.fetchItem(itemId) as Item;
  } catch (_) {
    return null;
  }
}