/// Kumpulan filter pencarian item.
class SearchFilters {
  static const double priceFloor = 0;
  static const double priceCeil = 1000000;

  final List<String> categoryIds;
  final double minPrice;
  final double maxPrice;
  final List<String> conditions; // nilai: baru, sangat_baik, baik, cukup
  final int? radiusKm; // null = semua

  const SearchFilters({
    this.categoryIds = const [],
    this.minPrice = priceFloor,
    this.maxPrice = priceCeil,
    this.conditions = const [],
    this.radiusKm,
  });

  bool get hasActiveFilter =>
      categoryIds.isNotEmpty ||
      conditions.isNotEmpty ||
      minPrice > priceFloor ||
      maxPrice < priceCeil ||
      radiusKm != null;

  int get activeCount {
    var count = 0;
    if (categoryIds.isNotEmpty) count++;
    if (conditions.isNotEmpty) count++;
    if (minPrice > priceFloor || maxPrice < priceCeil) count++;
    if (radiusKm != null) count++;
    return count;
  }

  SearchFilters copyWith({
    List<String>? categoryIds,
    double? minPrice,
    double? maxPrice,
    List<String>? conditions,
    int? radiusKm,
    bool clearRadius = false,
  }) =>
      SearchFilters(
        categoryIds: categoryIds ?? this.categoryIds,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        conditions: conditions ?? this.conditions,
        radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
      );
}