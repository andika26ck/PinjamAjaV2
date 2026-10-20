import '../../../../core/utils/formatters.dart';

class DepositRefundModel {
  final String paymentId;
  final String bookingId;
  final String? renterId;
  final double depositAmount;
  final double totalAmount;
  final String status; // pending|paid|expired|failed|refund_pending|refunded
  final DateTime? refundedAt;
  final String? refundProofUrl;
  final String? bookingStatus;
  final String? itemTitle;
  final String? renterName;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  const DepositRefundModel({
    required this.paymentId,
    required this.bookingId,
    this.renterId,
    this.depositAmount = 0,
    this.totalAmount = 0,
    this.status = 'paid',
    this.refundedAt,
    this.refundProofUrl,
    this.bookingStatus,
    this.itemTitle,
    this.renterName,
    this.bankName,
    this.accountNumber,
    this.accountName,
  });

  bool get isRefunded => status == 'refunded';
  bool get needsRefund => status == 'paid' && depositAmount > 0;
  bool get hasBankAccount =>
      (bankName?.isNotEmpty ?? false) && (accountNumber?.isNotEmpty ?? false);

  String get formattedDeposit => Formatters.rupiah(depositAmount);

  static DateTime? _d(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory DepositRefundModel.fromJson(Map<String, dynamic> json) {
    final renter = json['renter'] as Map<String, dynamic>?;
    final booking = json['booking'] as Map<String, dynamic>?;
    final item = booking?['item'] as Map<String, dynamic>?;
    return DepositRefundModel(
      paymentId: json['id'] as String,
      bookingId: json['booking_id'] as String,
      renterId: json['renter_id'] as String?,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'paid',
      refundedAt: _d(json['refunded_at']),
      refundProofUrl: json['refund_proof_url'] as String?,
      bookingStatus: booking?['status'] as String?,
      itemTitle: item?['title'] as String?,
      renterName: renter?['name'] as String?,
      bankName: renter?['payout_bank_name'] as String?,
      accountNumber: renter?['payout_account_number'] as String?,
      accountName: renter?['payout_account_name'] as String?,
    );
  }
}