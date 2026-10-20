import '../models/manual_payment_model.dart';
import '../models/payment_account_model.dart';

abstract class ManualPaymentRepository {
  Future<List<PaymentAccountModel>> fetchActiveAccounts();
  Future<ManualPaymentModel> createOrGetManualPayment(String bookingId);
  Future<ManualPaymentModel?> getPaymentByBooking(String bookingId);
  Stream<ManualPaymentModel?> watchPayment(String bookingId);
  Future<String> uploadProof(
      {required String bookingId, required String filePath});
  Future<void> submitProof({
    required String bookingId,
    required String proofPath,
    required String senderName,
    required String channel,
    required String accountId,
  });

  // Admin
  Future<List<Map<String, dynamic>>> fetchManualQueue({String? status});
  Future<String?> signedProofUrl(String path);
  Future<void> verifyManualPayment({
    required String paymentId,
    required bool approve,
    String? note,
  });
}