// lib/core/constants/app_config.dart
class AppConfig {
  static const bool isProduction =
      bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
  static const String midtransClientKey =
      String.fromEnvironment('MIDTRANS_CLIENT_KEY', defaultValue: '');
  static String get midtransSnapUrl => isProduction
      ? 'https://app.midtrans.com/snap/v2/vtweb'
      : 'https://app.sandbox.midtrans.com/snap/v2/vtweb';
}