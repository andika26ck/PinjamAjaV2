import '../../../../core/utils/formatters.dart';

enum PaymentStatusType {
  pending, paid, expired, failed, refundPending, refunded, unknown,
}

PaymentStatusType paymentStatusFrom(String? raw) {
  switch (raw) {
    case 'pending':
      return PaymentStatusType.pending;
    case 'paid':
      return PaymentStatusType.paid;
    case 'expired':
      return PaymentStatusType.expired;
    case 'failed':
      return PaymentStatusType.failed;
    case 'refund_pending':
      return PaymentStatusType.refundPending;
    case 'refunded':
      return PaymentStatusType.refunded;
    default:
      return PaymentStatusType.unknown;
  }
}

class PaymentModel {
  final String id;
  final String bookingId;
  final String? renterId;
  final String? ownerId;
  final String orderId;
  final String? snapToken;
  final String? snapRedirectUrl;
  final String? paymentMethod;
  final String? paymentChannel;
  final double rentalFee;
  final double depositAmount;
  final double platformFee;
  final double totalAmount;
  final PaymentStatusType status;
  final DateTime? paidAt;
  final DateTime? expiredAt;
  final DateTime? refundedAt;
  final double? refundAmount;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.orderId,
    required this.rentalFee,
    required this.depositAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    this.renterId,
    this.ownerId,
    this.snapToken,
    this.snapRedirectUrl,
    this.paymentMethod,
    this.paymentChannel,
    this.paidAt,
    this.expiredAt,
    this.refundedAt,
    this.refundAmount,
  });

  bool get isPaid => status == PaymentStatusType.paid;
  bool get isExpired => status == PaymentStatusType.expired;
  bool get isRefunded => status == PaymentStatusType.refunded;
  bool get canRetry =>
      status == PaymentStatusType.failed || status == PaymentStatusType.expired;

  String get formattedTotal => Formatters.rupiah(totalAmount);
  String get formattedRentalFee => Formatters.rupiah(rentalFee);
  String get formattedDeposit => Formatters.rupiah(depositAmount);
  String get formattedPlatformFee => Formatters.rupiah(platformFee);

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        renterId: json['renter_id'] as String?,
        ownerId: json['owner_id'] as String?,
        orderId: json['midtrans_order_id'] as String,
        snapToken: json['snap_token'] as String?,
        snapRedirectUrl: json['snap_redirect_url'] as String?,
        paymentMethod: json['payment_method'] as String?,
        paymentChannel: json['payment_channel'] as String?,
        rentalFee: (json['rental_fee'] as num).toDouble(),
        depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
        platformFee: (json['platform_fee'] as num).toDouble(),
        totalAmount: (json['total_amount'] as num).toDouble(),
        status: paymentStatusFrom(json['status'] as String?),
        paidAt: _date(json['paid_at']),
        expiredAt: _date(json['expired_at']),
        refundedAt: _date(json['refunded_at']),
        refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      );
}