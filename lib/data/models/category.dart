/// Model kategori (tabel `categories`).
class Category {
  final String id;
  final String name;
  final String? iconUrl;
  final String? slug;
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    this.iconUrl,
    this.slug,
    this.itemCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        iconUrl: json['icon_url'] as String?,
        slug: json['slug'] as String?,
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      );
}