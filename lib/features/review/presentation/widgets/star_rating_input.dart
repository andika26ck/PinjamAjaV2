import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 5 bintang interaktif dengan animasi “pop” saat dipilih.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 44,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final pos = i + 1;
        final selected = pos <= value;
        return GestureDetector(
          onTap: () => onChanged(pos),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: selected ? 1.15 : 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                selected ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size,
                color: selected ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}