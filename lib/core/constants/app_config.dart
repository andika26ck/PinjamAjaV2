// lib/core/constants/app_config.dart

/// Konfigurasi runtime yang dibaca dari --dart-define / dart_define.json.
/// TIDAK ada nilai rahasia (Server Key dll.) yang di-hardcode di sini.
class AppConfig {
  AppConfig._(); // class statik murni, cegah instansiasi

  /// true  = server Midtrans PRODUCTION (uang asli)
  /// false = SANDBOX (uang dummy) — default aman.
  /// Diisi dari env IS_PRODUCTION.
  static const bool isProduction =
      bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);

  /// Client Key Midtrans (aman tampil di sisi client/app).
  /// Sandbox    : SB-Mid-client-xxxx
  /// Production : Mid-client-xxxx  (tanpa prefix SB-)
  /// Diisi dari env MIDTRANS_CLIENT_KEY.
  static const String midtransClientKey =
      String.fromEnvironment('MIDTRANS_CLIENT_KEY', defaultValue: '');

  /// URL Snap sesuai environment aktif.
  static String get midtransSnapUrl => isProduction
      ? 'https://app.midtrans.com/snap/v2/vtweb'
      : 'https://app.sandbox.midtrans.com/snap/v2/vtweb';

  /// true kalau Client Key sudah diisi.
  /// Pakai ini buat guard sebelum membuka Snap, biar nggak buka
  /// halaman pembayaran dengan key kosong.
  static bool get isMidtransConfigured => midtransClientKey.isNotEmpty;

  /// Label environment — berguna untuk logging/debug.
  static String get midtransEnvLabel => isProduction ? 'PRODUCTION' : 'SANDBOX';
}