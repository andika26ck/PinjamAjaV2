import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_exception.dart';
import '../../providers/wishlist_provider.dart';

/// Tombol ♡ dengan animasi scale saat ditekan.
/// Merah (terisi) bila sudah di-wishlist, outline bila belum.
class WishlistButton extends ConsumerStatefulWidget {
  final String itemId;
  final double size;
  final Color? inactiveColor;
  final bool withBackground;

  const WishlistButton({
    super.key,
    required this.itemId,
    this.size = 24,
    this.inactiveColor,
    this.withBackground = false,
  });

  @override
  ConsumerState<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends ConsumerState<WishlistButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.0,
    upperBound: 0.3,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    // Animasi pop.
    await _controller.forward();
    await _controller.reverse();
    try {
      await ref.read(wishlistIdsProvider.notifier).toggle(widget.itemId);
    } catch (e) {
      if (!mounted) return;
      final msg = e is AppException ? e.message : 'Gagal memperbarui favorit.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(isWishlistedProvider(widget.itemId));
    final scale = 1 + _controller.value;

    final icon = AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.scale(scale: scale, child: child),
      child: Icon(
        active ? Icons.favorite : Icons.favorite_border,
        size: widget.size,
        color: active
            ? AppColors.error
            : (widget.inactiveColor ?? AppColors.textSecondary),
      ),
    );

    return InkWell(
      onTap: _onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: widget.withBackground
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: icon,
              )
            : icon,
      ),
    );
  }
}