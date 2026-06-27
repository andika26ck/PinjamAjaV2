import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/item.dart';
import '../../../data/models/review.dart';
import '../../../data/models/user_profile.dart';
import '../../review/data/review_repository.dart' show ReviewWithAuthor;
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;
  SupabaseProfileRepository(this._client);

  // Join reviewer agar ulasan menampilkan nama + avatar penulis.
  static const _reviewWithAuthorSelect =
      '*, reviewer:profiles!reviews_reviewer_id_fkey(name, avatar_url)';

  @override
  Future<UserProfile> fetchProfile(String userId) async {
    final data =
        await _client.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromJson(data);
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required String name,
    required String phone,
    UserRole? role,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      if (role != null) 'role': role.value,
    };
    final data = await _client
        .from('profiles')
        .update(payload)
        .eq('id', userId)
        .select()
        .single();
    return UserProfile.fromJson(data);
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final bucket = _client.storage.from(AppConstants.avatarsBucket);
    final ts = DateTime.now().millisecondsSinceEpoch;
    // Folder pertama = uid agar cocok dengan storage policy.
    final path = '$userId/avatar_$ts.$fileExtension';
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: fileExtension == 'png' ? 'image/png' : 'image/jpeg',
        upsert: true,
      ),
    );
    final url = bucket.getPublicUrl(path);
    await _client.from('profiles').update({'avatar_url': url}).eq('id', userId);
    return url;
  }

  @override
  Future<ProfileStats> fetchStats(String userId) async {
    // Booking selesai sebagai penyewa.
    final completedRows = await _client
        .from('bookings')
        .select('id')
        .eq('renter_id', userId)
        .eq('status', 'completed'); // sesuai AppConstants.bookingStatus
    final completed = (completedRows as List).length;

    // Barang yang dimiliki / disewakan.
    final itemRows =
        await _client.from('items').select('id').eq('owner_id', userId);
    final itemIds =
        (itemRows as List).map((e) => e['id'] as String).toList();

    // Ulasan yang diterima (di barang miliknya).
    var reviewsReceived = 0;
    if (itemIds.isNotEmpty) {
      final revRows = await _client
          .from('reviews')
          .select('id')
          .inFilter('item_id', itemIds);
      reviewsReceived = (revRows as List).length;
    }

    return ProfileStats(
      completedRentals: completed,
      itemsListed: itemIds.length,
      reviewsReceived: reviewsReceived,
    );
  }

  @override
  Future<List<Item>> fetchActiveItems(String userId) async {
    final rows = await _client
        .from('items')
        .select()
        .eq('owner_id', userId)
        .eq('status', 'available')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ReviewWithAuthor>> fetchReceivedReviews(String userId) async {
    final itemRows =
        await _client.from('items').select('id').eq('owner_id', userId);
    final itemIds =
        (itemRows as List).map((e) => e['id'] as String).toList();
    if (itemIds.isEmpty) return [];

    final rows = await _client
        .from('reviews')
        .select(_reviewWithAuthorSelect)
        .inFilter('item_id', itemIds)
        .order('created_at', ascending: false);

    return (rows as List).map((row) {
      final m = row as Map<String, dynamic>;
      final reviewer = m['reviewer'] as Map<String, dynamic>?;
      return ReviewWithAuthor(
        review: Review.fromJson(m),
        authorName: reviewer?['name'] as String?,
        authorAvatar: reviewer?['avatar_url'] as String?,
      );
    }).toList();
  }
}