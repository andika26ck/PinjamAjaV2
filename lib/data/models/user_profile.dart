/// Peran pengguna di PinjamAja.
enum UserRole {
  renter,
  owner;

  String get value => name;

  String get label => switch (this) {
        UserRole.renter => 'Penyewa',
        UserRole.owner => 'Pemilik',
      };

  static UserRole? fromValue(String? value) => switch (value) {
        'renter' => UserRole.renter,
        'owner' => UserRole.owner,
        _ => null,
      };
}

/// Model profil pengguna (tabel `profiles`).
class UserProfile {
  final String id;
  final String? name;
  final String? phone;
  final UserRole? role;
  final String? avatarUrl;
  final double rating;
  final int totalTransactions;
  final bool isVerified;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.name,
    this.phone,
    this.role,
    this.avatarUrl,
    this.rating = 0,
    this.totalTransactions = 0,
    this.isVerified = false,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: UserRole.fromValue(json['role'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role?.value,
        'avatar_url': avatarUrl,
      };

  UserProfile copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    UserRole? role,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      rating: rating,
      totalTransactions: totalTransactions,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }
}