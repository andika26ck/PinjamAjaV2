/// Konstanta global aplikasi & konfigurasi Supabase.
class AppConstants {
  AppConstants._();

  static const String appName = 'PinjamAja';

  // Isi via --dart-define saat run/build, atau ganti default di bawah.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR-ANON-KEY',
  );

  // Storage buckets
  static const String itemImagesBucket = 'item-images';
  static const String avatarsBucket = 'avatars';

  // Deep link untuk OAuth / reset password (sesuaikan native config).
  static const String oauthRedirectUrl = 'io.pinjamaja://login-callback/';
}