import '../../../../core/utils/formatters.dart';

/// Model pembayaran manual — membaca tabel `payments`.
class ManualPaymentModel {
  final String id;
  final String bookingId;
  final String status; // pending | paid | expired | failed | refund_pending | refunded
  final double rentalFee;
  final double depositAmount;
  final double platformFee;
  final double totalAmount;
  final String? proofUrl;       // path objek di bucket payment-proofs
  final String? senderName;
  final String? manualChannel;  // qris | bank_transfer
  final String? rejectedReason;
  final DateTime? proofSubmittedAt;
  final DateTime? paidAt;

  const ManualPaymentModel({
    required this.id,
    required this.bookingId,
    required this.status,
    this.rentalFee = 0,
    this.depositAmount = 0,
    this.platformFee = 0,
    this.totalAmount = 0,
    this.proofUrl,
    this.senderName,
    this.manualChannel,
    this.rejectedReason,
    this.proofSubmittedAt,
    this.paidAt,
  });

  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'failed';
  bool get hasProof => proofUrl != null && proofUrl!.isNotEmpty;
  bool get awaitingVerification => hasProof && status == 'pending';

  String get formattedTotal => Formatters.rupiah(totalAmount);
  String get channelLabel =>
      manualChannel == 'qris' ? 'QRIS' : 'Transfer Bank';

  static DateTime? _d(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory ManualPaymentModel.fromJson(Map<String, dynamic> json) =>
      ManualPaymentModel(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        status: json['status'] as String? ?? 'pending',
        rentalFee: (json['rental_fee'] as num?)?.toDouble() ?? 0,
        depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
        platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        proofUrl: json['proof_url'] as String?,
        senderName: json['sender_name'] as String?,
        manualChannel: json['manual_channel'] as String?,
        rejectedReason: json['rejected_reason'] as String?,
        proofSubmittedAt: _d(json['proof_submitted_at']),
        paidAt: _d(json['paid_at']),
      );
}