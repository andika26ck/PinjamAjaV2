import 'package:flutter/material.dart';

/// Overlay semi-transparan dengan loading indicator.
/// Bungkus konten dengan widget ini & kontrol via boolean `isLoading`.
///
/// Contoh:
///   LoadingOverlay(
///     isLoading: controller.isLoading,
///     message: 'Menyimpan...',
///     child: MyForm(),
///   )
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: ColoredBox(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      if (message != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          message!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}