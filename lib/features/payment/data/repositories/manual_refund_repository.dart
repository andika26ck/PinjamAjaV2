import '../models/deposit_refund_model.dart';

abstract class ManualRefundRepository {
  Future<List<DepositRefundModel>> fetchRefundQueue({String? status});
  Future<String> uploadRefundProof({
    required String renterId,
    required String paymentId,
    required String filePath,
  });
  Future<String?> signedRefundProofUrl(String path);
  Future<void> refundDeposit({
    required String paymentId,
    String? proofPath,
    String? note,
  });
}