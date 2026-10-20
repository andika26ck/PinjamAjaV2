/// Model sengketa terkait booking (tabel `disputes`).
class Dispute {
  final String id;
  final String bookingId;
  final String openedBy;
  final String? againstId;
  final String reason;
  final String? description;
  final List<String> evidenceUrls;
  final String status; // open | reviewing | resolved | rejected
  final String? resolution;
  // resolution: refund_renter | pay_owner | partial_refund | deduct_deposit | no_action
  final String? resolutionNote;
  final double? refundAmount;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  const Dispute({
    required this.id,
    required this.bookingId,
    required this.openedBy,
    this.againstId,
    required this.reason,
    this.description,
    this.evidenceUrls = const [],
    this.status = 'open',
    this.resolution,
    this.resolutionNote,
    this.refundAmount,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
  });

  bool get isOpen => status == 'open' || status == 'reviewing';

  String get statusLabel => switch (status) {
        'open' => 'Baru',
        'reviewing' => 'Ditinjau',
        'resolved' => 'Selesai',
        'rejected' => 'Ditolak',
        _ => status,
      };

  static String resolutionLabel(String? r) => switch (r) {
        'refund_renter' => 'Refund penuh ke penyewa',
        'pay_owner' => 'Cairkan ke pemilik',
        'partial_refund' => 'Refund sebagian',
        'deduct_deposit' => 'Potong deposit',
        'no_action' => 'Tanpa tindakan',
        _ => '-',
      };

  factory Dispute.fromJson(Map<String, dynamic> json) {
    DateTime? p(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    List<String> strList(dynamic raw) =>
        raw is List ? raw.map((e) => e.toString()).toList() : const [];
    return Dispute(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String? ?? '',
      openedBy: json['opened_by'] as String? ?? '',
      againstId: json['against_id'] as String?,
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      evidenceUrls: strList(json['evidence_urls']),
      status: json['status'] as String? ?? 'open',
      resolution: json['resolution'] as String?,
      resolutionNote: json['resolution_note'] as String?,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: p(json['resolved_at']),
      createdAt: p(json['created_at']),
    );
  }
}