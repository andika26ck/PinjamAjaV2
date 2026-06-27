import 'package:flutter/material.dart';

/// Palet warna utama PinjamAja.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2563EB); // biru
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFFF59E0B); // amber/kuning
  static const Color secondaryDark = Color(0xFFD97706);

  // Surface & background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Teks
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Border & divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Feedback
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Status booking (semantic)
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusActive = Color(0xFF2563EB);
  static const Color statusCompleted = Color(0xFF22C55E);
  static const Color statusCancelled = Color(0xFFEF4444);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}