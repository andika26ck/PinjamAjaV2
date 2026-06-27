import '../models/payment_model.dart';
import '../models/payment_request_model.dart';

abstract class PaymentRepository {
  Future<PaymentRequestModel> createPayment(String bookingId);
  Future<PaymentModel?> getPaymentByBookingId(String bookingId);
  Stream<PaymentModel?> watchPayment(String bookingId); // Realtime
  Future<void> requestRefund(String bookingId, {String? reason});
}