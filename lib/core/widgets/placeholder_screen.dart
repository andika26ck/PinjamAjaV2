import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Layar sementara untuk route yang belum diimplementasikan (Fase berikutnya).
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '$title\n(belum diimplementasikan)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}