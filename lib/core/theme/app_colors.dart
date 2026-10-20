import 'package:flutter/material.dart';

/// Palet warna terpusat PinjamAja.
/// Pakai di mana saja: `AppColors.primary`, `AppColors.error`, dst.
class AppColors {
  AppColors._();

  // ---------- Brand ----------
  static const Color primary = Color(0xFF2563EB); // biru utama
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primarySoft = Color(0xFFEFF4FF); // bg lembut / chip aktif

  static const Color secondary = Color(0xFF0EA5E9);
  static const Color accent = Color(0xFFF59E0B); // aksen oranye (rating, dll)

  // ---------- Status ----------
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // ---------- Status booking (selaras bookingStatusColor) ----------
  static const Color statusPending = Color(0xFFF59E0B); // menunggu
  static const Color statusConfirmed = Color(0xFF2563EB); // dikonfirmasi
  static const Color statusActive = Color(0xFF16A34A); // berlangsung
  static const Color statusCompleted = Color(0xFF6B7280); // selesai
  static const Color statusCancelled = Color(0xFFDC2626); // dibatalkan

  // ---------- Netral / Teks ----------
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------- Surface / Background ----------
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5); // fill input/card abu
  static const Color scaffold = Color(0xFFFAFAFA);

  // ---------- Border / Divider ----------
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEEEEE);

  // ---------- Lain-lain ----------
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color overlay = Color(0x66000000); // hitam 40%

  // ---------- Gradient (opsional) ----------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}