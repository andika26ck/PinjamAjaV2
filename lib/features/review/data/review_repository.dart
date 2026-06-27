import '../../../data/models/review.dart';

/// Data ringan ulasan + identitas penulis (hasil join reviews ↔ profiles).
class ReviewWithAuthor {
  final Review review;
  final String? authorName;
  final String? authorAvatar;

  const ReviewWithAuthor({
    required this.review,
    this.authorName,
    this.authorAvatar,
  });
}

abstract class ReviewRepository {
  /// Semua ulasan untuk satu item (terbaru dulu), lengkap dengan penulis.
  Future<List<ReviewWithAuthor>> fetchItemReviews(String itemId);

  /// Kirim ulasan baru. Mengembalikan review yang tersimpan.
  Future<Review> submitReview({
    required String bookingId,
    required String itemId,
    required String reviewerId,
    required int rating,
    required String comment,
  });

  /// True jika booking ini sudah pernah diulas.
  Future<bool> hasReviewed(String bookingId);
}