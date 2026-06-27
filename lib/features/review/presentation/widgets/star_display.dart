import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Bintang read-only. Mendukung nilai pecahan (mis. 4.3) via half-star.
class StarDisplay extends StatelessWidget {
  const StarDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  final double rating;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final pos = i + 1;
        IconData icon;
        if (rating >= pos) {
          icon = Icons.star_rounded;
        } else if (rating >= pos - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: size, color: c);
      }),
    );
  }
}