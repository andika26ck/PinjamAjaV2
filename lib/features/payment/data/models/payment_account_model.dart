class PaymentAccountModel {
  final String id;
  final String type; // 'qris' | 'bank'
  final String label;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? qrisImageUrl;
  final bool isActive;
  final int sortOrder;

  const PaymentAccountModel({
    required this.id,
    required this.type,
    required this.label,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.qrisImageUrl,
    this.isActive = true,
    this.sortOrder = 0,
  });

  bool get isQris => type == 'qris';
  bool get isBank => type == 'bank';

  factory PaymentAccountModel.fromJson(Map<String, dynamic> json) =>
      PaymentAccountModel(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'bank',
        label: json['label'] as String? ?? '',
        bankName: json['bank_name'] as String?,
        accountNumber: json['account_number'] as String?,
        accountName: json['account_name'] as String?,
        qrisImageUrl: json['qris_image_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );
}