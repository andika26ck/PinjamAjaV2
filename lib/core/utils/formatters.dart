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

  /// Format DateTime -> "28 Jun 2026, 14:05" (waktu lokal).
  static String dateTime(DateTime value) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final d = value.toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${bulan[d.month - 1]} ${d.year}, $hh:$mm';
  }
}