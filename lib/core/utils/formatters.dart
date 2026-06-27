/// Helper format angka & teks untuk PinjamAja.
class Formatters {
  Formatters._();

  /// Format angka menjadi Rupiah, mis. 150000 -> "Rp150.000".
  static String rupiah(num value) {
    final digits = value.round().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    final sign = value < 0 ? '-' : '';
    return '${sign}Rp$buffer';
  }

  /// Mis. 150000 -> "Rp150.000/hari".
  static String rupiahPerDay(num value) => '${rupiah(value)}/hari';
}