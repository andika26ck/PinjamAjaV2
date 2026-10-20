import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception kustom seluruh aplikasi PinjamAja.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Ubah error apa pun (terutama dari Supabase) menjadi [AppException]
/// dengan pesan ramah dalam Bahasa Indonesia.
extension AppExceptionMapper on Object {
  AppException toAppException() {
    final error = this;
    if (error is AppException) return error;
    if (error is AuthException) {
      return AppException(_mapAuthMessage(error.message),
          code: error.statusCode);
    }
    if (error is PostgrestException) {
      return AppException(_mapPostgrestMessage(error), code: error.code);
    }
    if (error is StorageException) {
      return AppException('Gagal memproses file. Silakan coba lagi.',
          code: error.statusCode);
    }
    return AppException('Terjadi kesalahan: $error', code: 'unknown');
  }
}

String _mapAuthMessage(String raw) {
  final msg = raw.toLowerCase();
  if (msg.contains('invalid login credentials')) {
    return 'Email atau kata sandi salah.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Email belum diverifikasi. Cek kotak masuk kamu.';
  }
  if (msg.contains('already registered') ||
      msg.contains('already been registered') ||
      msg.contains('user already')) {
    return 'Email ini sudah terdaftar. Silakan masuk.';
  }
  if (msg.contains('password should be at least')) {
    return 'Kata sandi minimal 6 karakter.';
  }
  if (msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('failed host lookup')) {
    return 'Koneksi bermasalah. Periksa internet kamu.';
  }
  if (msg.contains('api key') || msg.contains('invalid api')) {
    return 'API key Supabase tidak valid. Cek SUPABASE_ANON_KEY di dart_define.json.';
  }
  if (msg.contains('signups not allowed') || msg.contains('signup is disabled')) {
    return 'Pendaftaran sedang dinonaktifkan di Supabase (Authentication → Providers → Email).';
  }
  if (msg.contains('database error')) {
    return 'Gagal menyimpan user baru di database. Detail: $raw';
  }
  // Tampilkan pesan asli supaya mudah debug.
  return 'Gagal memproses autentikasi: $raw';
}

String _mapPostgrestMessage(PostgrestException e) {
  switch (e.code) {
    case '23505':
      return 'Data sudah ada (duplikat). ${e.message}';
    case '23503':
      return 'Data terkait tidak ditemukan.';
    case '42501':
      return 'Akses ditolak oleh RLS (kemungkinan policy INSERT belum ada). ${e.message}';
    default:
      return 'Gagal memuat data: ${e.message}';
  }
}