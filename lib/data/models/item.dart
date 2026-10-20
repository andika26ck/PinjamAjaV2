/// Kondisi barang.
enum ItemCondition {
  baru,
  sangatBaik,
  baik,
  cukup;

  String get value => switch (this) {
        ItemCondition.baru => 'baru',
        ItemCondition.sangatBaik => 'sangat_baik',
        ItemCondition.baik => 'baik',
        ItemCondition.cukup => 'cukup',
      };

  String get label => switch (this) {
        ItemCondition.baru => 'Baru',
        ItemCondition.sangatBaik => 'Sangat Baik',
        ItemCondition.baik => 'Baik',
        ItemCondition.cukup => 'Cukup',
      };

  static ItemCondition? fromValue(String? value) => switch (value) {
        'baru' => ItemCondition.baru,
        'sangat_baik' => ItemCondition.sangatBaik,
        'baik' => ItemCondition.baik,
        'cukup' => ItemCondition.cukup,
        _ => null,
      };
}

/// Model barang (tabel `items`).
class Item {
  final String id;
  final String ownerId;
  final String categoryId;
  final String title;
  final String description;
  final int pricePerDay;
  final int depositAmount;
  final List<String> imageUrls;
  final ItemCondition? condition;
  final String status;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<DateTime> blockedDates;
  final double rating;
  final int totalReviews;
  final DateTime? createdAt;

  // --- Moderasi admin (Fase 2 admin) ---
  final String moderationStatus; // ok | flagged | removed
  final String? moderationNote;

  const Item({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.title,
    this.description = '',
    this.pricePerDay = 0,
    this.depositAmount = 0,
    this.imageUrls = const [],
    this.condition,
    this.status = 'available',
    this.location,
    this.latitude,
    this.longitude,
    this.blockedDates = const [],
    this.rating = 0,
    this.totalReviews = 0,
    this.createdAt,
    this.moderationStatus = 'ok',
    this.moderationNote,
  });

  String? get thumbnailUrl => imageUrls.isEmpty ? null : imageUrls.first;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricePerDay: (json['price_per_day'] as num?)?.toInt() ?? 0,
      depositAmount: (json['deposit_amount'] as num?)?.toInt() ?? 0,
      imageUrls: _stringList(json['image_urls']),
      condition: ItemCondition.fromValue(json['condition'] as String?),
      status: json['status'] as String? ?? 'available',
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      blockedDates: _dateList(json['blocked_dates']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
      moderationStatus: json['moderation_status'] as String? ?? 'ok',
      moderationNote: json['moderation_note'] as String?,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  static List<DateTime> _dateList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => DateTime.tryParse(e.toString()))
          .whereType<DateTime>()
          .toList();
    }
    return const [];
  }
}