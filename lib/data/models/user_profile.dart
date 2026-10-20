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

  // --- Admin & moderasi (Fase 2 admin) ---
  final bool isAdmin;
  final bool isSuspended;
  final String? suspendedReason;
  final DateTime? suspendedAt;

  // --- KYC (verifikasi identitas) ---
  final String kycStatus; // none | pending | verified | rejected
  final String? kycFullName;
  final String? kycIdNumber;
  final String? kycIdPhotoUrl;
  final String? kycSelfieUrl;
  final DateTime? kycSubmittedAt;
  final DateTime? kycReviewedAt;
  final String? kycReviewedBy;
  final String? kycRejectReason;

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
    this.isAdmin = false,
    this.isSuspended = false,
    this.suspendedReason,
    this.suspendedAt,
    this.kycStatus = 'none',
    this.kycFullName,
    this.kycIdNumber,
    this.kycIdPhotoUrl,
    this.kycSelfieUrl,
    this.kycSubmittedAt,
    this.kycReviewedAt,
    this.kycReviewedBy,
    this.kycRejectReason,
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
      isAdmin: json['is_admin'] as bool? ?? false,
      isSuspended: json['is_suspended'] as bool? ?? false,
      suspendedReason: json['suspended_reason'] as String?,
      suspendedAt: json['suspended_at'] == null
          ? null
          : DateTime.tryParse(json['suspended_at'] as String),
      kycStatus: json['kyc_status'] as String? ?? 'none',
      kycFullName: json['kyc_full_name'] as String?,
      kycIdNumber: json['kyc_id_number'] as String?,
      kycIdPhotoUrl: json['kyc_id_photo_url'] as String?,
      kycSelfieUrl: json['kyc_selfie_url'] as String?,
      kycSubmittedAt: json['kyc_submitted_at'] == null
          ? null
          : DateTime.tryParse(json['kyc_submitted_at'] as String),
      kycReviewedAt: json['kyc_reviewed_at'] == null
          ? null
          : DateTime.tryParse(json['kyc_reviewed_at'] as String),
      kycReviewedBy: json['kyc_reviewed_by'] as String?,
      kycRejectReason: json['kyc_reject_reason'] as String?,
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
      isAdmin: isAdmin,
      isSuspended: isSuspended,
      suspendedReason: suspendedReason,
      suspendedAt: suspendedAt,
      kycStatus: kycStatus,
      kycFullName: kycFullName,
      kycIdNumber: kycIdNumber,
      kycIdPhotoUrl: kycIdPhotoUrl,
      kycSelfieUrl: kycSelfieUrl,
      kycSubmittedAt: kycSubmittedAt,
      kycReviewedAt: kycReviewedAt,
      kycReviewedBy: kycReviewedBy,
      kycRejectReason: kycRejectReason,
    );
  }

  // Helper status KYC.
  bool get kycVerified => kycStatus == 'verified';
  bool get kycPending => kycStatus == 'pending';
  bool get kycRejected => kycStatus == 'rejected';
  bool get kycNone => kycStatus == 'none';
}