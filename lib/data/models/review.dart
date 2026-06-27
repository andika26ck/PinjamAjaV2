/// Model ulasan (tabel `reviews`). `reviewerName`/`reviewerAvatarUrl`
/// diisi via query profil terpisah di repository.
class Review {
  final String id;
  final String bookingId;
  final String itemId;
  final String reviewerId;
  final double rating;
  final String? comment;
  final DateTime? createdAt;
  final String? reviewerName;
  final String? reviewerAvatarUrl;

  const Review({
    required this.id,
    required this.bookingId,
    required this.itemId,
    required this.reviewerId,
    this.rating = 0,
    this.comment,
    this.createdAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      reviewerId: json['reviewer_id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  Review withReviewer({String? name, String? avatarUrl}) => Review(
        id: id,
        bookingId: bookingId,
        itemId: itemId,
        reviewerId: reviewerId,
        rating: rating,
        comment: comment,
        createdAt: createdAt,
        reviewerName: name ?? reviewerName,
        reviewerAvatarUrl: avatarUrl ?? reviewerAvatarUrl,
      );
}