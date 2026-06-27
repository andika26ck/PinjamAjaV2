import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';
import '../../../data/models/review.dart';
import 'review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  SupabaseReviewRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<ReviewWithAuthor>> fetchItemReviews(String itemId) async {
    try {
      // Join ke profiles untuk nama & avatar penulis.
      final rows = await _client
          .from('reviews')
          .select('*, reviewer:profiles!reviews_reviewer_id_fkey(name, avatar_url)')
          .eq('item_id', itemId)
          .order('created_at', ascending: false);

      return (rows as List).map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        final author = map['reviewer'] as Map<String, dynamic>?;
        return ReviewWithAuthor(
          review: Review.fromJson(map),
          authorName: author?['name'] as String?,
          authorAvatar: author?['avatar_url'] as String?,
        );
      }).toList();
    } catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<Review> submitReview({
    required String bookingId,
    required String itemId,
    required String reviewerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final inserted = await _client
          .from('reviews')
          .insert({
            'booking_id': bookingId,
            'item_id': itemId,
            'reviewer_id': reviewerId,
            'rating': rating,
            'comment': comment.trim(),
          })
          .select()
          .single();
      // Rating item & profil owner diperbarui otomatis oleh trigger SQL.
      return Review.fromJson(Map<String, dynamic>.from(inserted));
    } catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<bool> hasReviewed(String bookingId) async {
    try {
      final row = await _client
          .from('reviews')
          .select('id')
          .eq('booking_id', bookingId)
          .maybeSingle();
      return row != null;
    } catch (e) {
      throw e.toAppException();
    }
  }
}