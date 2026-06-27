// CATATAN: file default `flutter create` di sini awalnya widget test yang
// pump `MyApp` — class itu sudah diganti jadi `PinjamAjaApp` (lihat
// lib/app.dart). Belum diganti jadi widget test penuh untuk PinjamAjaApp
// karena app butuh Supabase.initialize() jalan dulu (dipanggil di main(),
// bukan di app.dart) — testing itu butuh mock Supabase client yang belum
// dibuat di Prompt #1 ini. Untuk sekarang, smoke-test logic murni dulu.
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjam_aja/core/utils/price_helper.dart';

void main() {
  test('PriceHelper.calculatePlatformFee menghitung 5% dengan benar', () {
    final fee = PriceHelper.calculatePlatformFee(3, 100000);
    expect(fee, 15000);
  });

  test('PriceHelper.calculateTotalPrice menjumlahkan sewa + deposit + fee', () {
    final total = PriceHelper.calculateTotalPrice(
      totalDays: 3,
      pricePerDay: 100000,
      depositAmount: 50000,
    );
    // (3 * 100000) + 50000 + (3 * 100000 * 0.05) = 300000 + 50000 + 15000
    expect(total, 365000);
  });
}
