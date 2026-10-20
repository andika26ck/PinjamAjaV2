import '../models/payout_account.dart';
import '../models/payout_model.dart';

abstract class ManualPayoutRepository {
  Future<PayoutAccount> getMyPayoutAccount();
  Future<void> updateMyPayoutAccount({
    required String bankName,
    required String accountNumber,
    required String accountName,
  });
  Future<List<ManualPayoutModel>> fetchPayoutQueue({String? status});
  Future<String> uploadPayoutProof({
    required String ownerId,
    required String payoutId,
    required String filePath,
  });
  Future<String?> signedPayoutProofUrl(String path);
  Future<void> completePayout({
    required String payoutId,
    String? proofPath,
    String? note,
  });
}