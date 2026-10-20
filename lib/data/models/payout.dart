/// Model pencairan dana ke pemilik / escrow (tabel `payouts`).
class Payout {
  final String id;
  final String? paymentId;
  final String ownerId;
  final String? bookingId;
  final int grossAmount;
  final int platformFee;
  final int netAmount;
  final String status; // pending | processed | completed | failed
  final DateTime? scheduledAt;
  final DateTime? processedAt;
  final DateTime? createdAt;

  const Payout({
    required this.id,
    this.paymentId,
    required this.ownerId,
    this.bookingId,
    this.grossAmount = 0,
    this.platformFee = 0,
    this.netAmount = 0,
    this.status = 'pending',
    this.scheduledAt,
    this.processedAt,
    this.createdAt,
  });

  bool get isPending => status == 'pending' || status == 'processed';

  String get statusLabel => switch (status) {
        'pending' => 'Menunggu',
        'processed' => 'Diproses',
        'completed' => 'Selesai',
        'failed' => 'Gagal',
        _ => status,
      };

  factory Payout.fromJson(Map<String, dynamic> json) {
    DateTime? p(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Payout(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String?,
      ownerId: json['owner_id'] as String? ?? '',
      bookingId: json['booking_id'] as String?,
      grossAmount: (json['gross_amount'] as num?)?.toInt() ?? 0,
      platformFee: (json['platform_fee'] as num?)?.toInt() ?? 0,
      netAmount: (json['net_amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      scheduledAt: p(json['scheduled_at']),
      processedAt: p(json['processed_at']),
      createdAt: p(json['created_at']),
    );
  }
}