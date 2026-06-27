import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_exception.dart';
import '../models/payment_model.dart';
import '../models/payment_request_model.dart';
import 'payment_repository.dart';

class SupabasePaymentRepository implements PaymentRepository {
  final SupabaseClient _client;
  SupabasePaymentRepository(this._client);

  @override
  Future<PaymentRequestModel> createPayment(String bookingId) async {
    try {
      final res = await _client.functions.invoke(
        'create-payment',
        body: {'booking_id': bookingId},
      );
      final data = res.data;
      if (res.status != 200 || data == null) {
        final msg = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Gagal memulai pembayaran. Coba lagi.';
        throw AppException(msg);
      }
      return PaymentRequestModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on FunctionException catch (e) {
      final details = e.details;
      final msg = (details is Map && details['message'] != null)
          ? details['message'].toString()
          : 'Gagal memulai pembayaran.';
      throw AppException(msg);
    }
  }

  @override
  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    final rows = await _client
        .from('payments')
        .select()
        .eq('booking_id', bookingId)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return PaymentModel.fromJson(list.first as Map<String, dynamic>);
  }

  @override
  Stream<PaymentModel?> watchPayment(String bookingId) {
    return _client
        .from('payments')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .map((rows) =>
            rows.isEmpty ? null : PaymentModel.fromJson(rows.first));
  }

  @override
  Future<void> requestRefund(String bookingId, {String? reason}) async {
    final res = await _client.functions.invoke(
      'process-refund',
      body: {'booking_id': bookingId, 'reason': reason},
    );
    if (res.status != 200) {
      final data = res.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Gagal memproses refund.';
      throw AppException(msg);
    }
  }
}