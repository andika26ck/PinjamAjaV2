import 'package:flutter_test/flutter_test.dart';
import 'package:pinjam_aja/core/utils/formatters.dart';

void main() {
  group('Formatters.rupiah', () {
    test('format ribuan pakai pemisah titik', () {
      expect(Formatters.rupiah(999), 'Rp999');
      expect(Formatters.rupiah(1000), 'Rp1.000');
      expect(Formatters.rupiah(150000), 'Rp150.000');
    });

    test('format angka besar', () {
      expect(Formatters.rupiah(1250000), 'Rp1.250.000');
      expect(Formatters.rupiah(10000000), 'Rp10.000.000');
    });

    test('nilai nol', () {
      expect(Formatters.rupiah(0), 'Rp0');
    });

    test('nilai desimal dibulatkan', () {
      expect(Formatters.rupiah(150000.4), 'Rp150.000');
      expect(Formatters.rupiah(150000.6), 'Rp150.001');
    });

    test('nilai negatif diberi tanda minus', () {
      expect(Formatters.rupiah(-5000), '-Rp5.000');
    });
  });

  group('Formatters.rupiahPerDay', () {
    test('menambah sufiks /hari', () {
      expect(Formatters.rupiahPerDay(75000), 'Rp75.000/hari');
    });
  });

  group('Formatters.dateTime', () {
    test('memformat tanggal & jam lokal', () {
      final d = DateTime(2026, 6, 28, 14, 5);
      expect(Formatters.dateTime(d), '28 Jun 2026, 14:05');
    });

    test('jam & menit dipadkan dua digit', () {
      final d = DateTime(2026, 1, 9, 3, 7);
      expect(Formatters.dateTime(d), '9 Jan 2026, 03:07');
    });
  });
}