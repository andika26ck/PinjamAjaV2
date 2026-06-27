/// Model pemesanan (tabel `bookings`).
class Booking {
  final String id;
  final String itemId;
  final String renterId;
  final String ownerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalDay;
  final int pricePerDay;
  final int depositAmount;
  final int platformFee;
  final int totalPrice;
  final String status;
  final String paymentStatus;
  final String? cancellationReason;
  final String? notes;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.itemId,
    required this.renterId,
    required this.ownerId,
    this.startDate,
    this.endDate,
    this.totalDay = 0,
    this.pricePerDay = 0,
    this.depositAmount = 0,
    this.platformFee = 0,
    this.totalPrice = 0,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.cancellationReason,
    this.notes,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime? p(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Booking(
      id: json['id'] as String,
      itemId: json['item_id'] as String? ?? '',
      renterId: json['renter_id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      startDate: p(json['start_date']),
      endDate: p(json['end_date']),
      totalDay: (json['total_day'] as num?)?.toInt() ?? 0,
      pricePerDay: (json['price_per_day'] as num?)?.toInt() ?? 0,
      depositAmount: (json['deposit_amount'] as num?)?.toInt() ?? 0,
      platformFee: (json['platform_fee'] as num?)?.toInt() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      cancellationReason: json['cancellation_reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: p(json['created_at']),
    );
  }
}