class PaymentRequestModel {
  final String snapToken;
  final String? snapRedirectUrl;
  final String orderId;
  final double totalAmount;
  final DateTime? expiredAt;

  const PaymentRequestModel({
    required this.snapToken,
    required this.orderId,
    required this.totalAmount,
    this.snapRedirectUrl,
    this.expiredAt,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      PaymentRequestModel(
        snapToken: json['snap_token'] as String,
        snapRedirectUrl: json['snap_redirect_url'] as String?,
        orderId: json['order_id'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        expiredAt: json['expired_at'] != null
            ? DateTime.tryParse(json['expired_at'] as String)
            : null,
      );
}