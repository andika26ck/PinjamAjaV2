import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/app_exception.dart';

/// Tampilan error konsisten + tombol “Coba Lagi”.
/// Membedakan error jaringan (network) vs error server/umum.
class AppErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final bool compact;

  const AppErrorView({
    super.key,
    this.error,
    this.onRetry,
    this.compact = false,
  });

  bool get _isNetwork {
    final s = (error?.toString() ?? '').toLowerCase();
    return s.contains('socket') ||
        s.contains('network') ||
        s.contains('internet') ||
        s.contains('koneksi') ||
        s.contains('timeout') ||
        s.contains('failed host');
  }

  String get _message {
    if (error is AppException) return (error as AppException).message;
    if (_isNetwork) {
      return 'Tidak ada koneksi internet. Periksa jaringanmu lalu coba lagi.';
    }
    return 'Terjadi kesalahan pada server. Silakan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final icon =
        _isNetwork ? Icons.wifi_off_rounded : Icons.cloud_off_rounded;
    final title = _isNetwork ? 'Masalah Koneksi' : 'Terjadi Kesalahan';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: compact ? 40 : 56, color: AppColors.textTertiary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textTertiary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}