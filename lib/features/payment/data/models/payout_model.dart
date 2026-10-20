import '../../../../core/utils/formatters.dart';

class ManualPayoutModel {
  final String id;
  final String? paymentId;
  final String bookingId;
  final String ownerId;
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final String status; // pending | processed | completed | failed
  final DateTime? scheduledAt;
  final DateTime? transferredAt;
  final String? transferProofUrl;
  final String? transferNote;

  // Hasil join
  final String? ownerName;
  final String? payoutBankName;
  final String? payoutAccountNumber;
  final String? payoutAccountName;
  final String? itemTitle;

  const ManualPayoutModel({
    required this.id,
    required this.bookingId,
    required this.ownerId,
    this.paymentId,
    this.grossAmount = 0,
    this.platformFee = 0,
    this.netAmount = 0,
    this.status = 'pending',
    this.scheduledAt,
    this.transferredAt,
    this.transferProofUrl,
    this.transferNote,
    this.ownerName,
    this.payoutBankName,
    this.payoutAccountNumber,
    this.payoutAccountName,
    this.itemTitle,
  });

  bool get isPending => status == 'pending' || status == 'processed';
  bool get isCompleted => status == 'completed';
  bool get hasPayoutAccount =>
      (payoutBankName?.isNotEmpty ?? false) &&
      (payoutAccountNumber?.isNotEmpty ?? false);

  String get formattedNet => Formatters.rupiah(netAmount);
  String get formattedGross => Formatters.rupiah(grossAmount);
  String get statusLabel => switch (status) {
        'completed' => 'Sudah dicairkan',
        'failed' => 'Gagal',
        'processed' => 'Diproses',
        _ => 'Menunggu pencairan',
      };

  static DateTime? _d(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory ManualPayoutModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final booking = json['booking'] as Map<String, dynamic>?;
    final item = booking?['item'] as Map<String, dynamic>?;
    return ManualPayoutModel(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String?,
      bookingId: json['booking_id'] as String,
      ownerId: json['owner_id'] as String,
      grossAmount: (json['gross_amount'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      scheduledAt: _d(json['scheduled_at']),
      transferredAt: _d(json['transferred_at']),
      transferProofUrl: json['transfer_proof_url'] as String?,
      transferNote: json['transfer_note'] as String?,
      ownerName: owner?['name'] as String?,
      payoutBankName: owner?['payout_bank_name'] as String?,
      payoutAccountNumber: owner?['payout_account_number'] as String?,
      payoutAccountName: owner?['payout_account_name'] as String?,
      itemTitle: item?['title'] as String?,
    );
  }
}