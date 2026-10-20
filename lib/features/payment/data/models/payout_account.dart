class PayoutAccount {
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  const PayoutAccount({this.bankName, this.accountNumber, this.accountName});

  bool get isComplete =>
      (bankName?.isNotEmpty ?? false) &&
      (accountNumber?.isNotEmpty ?? false) &&
      (accountName?.isNotEmpty ?? false);

  factory PayoutAccount.fromJson(Map<String, dynamic> json) => PayoutAccount(
        bankName: json['payout_bank_name'] as String?,
        accountNumber: json['payout_account_number'] as String?,
        accountName: json['payout_account_name'] as String?,
      );
}