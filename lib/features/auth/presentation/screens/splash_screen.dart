import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Animasi masuk (muncul membal)
  late final AnimationController _entryCtrl;
  // Animasi looping (muter + napas)
  late final AnimationController _loopCtrl;

  late final Animation<double> _entryScale;
  late final Animation<double> _entryFade;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Efek membal seperti karet
    _entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    // Muncul transparan -> jelas
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Muter penuh + napas, berulang tiap 4 detik
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Efek napas: 1.0 -> 1.06 -> 1.0
    _pulseScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_loopCtrl);

    _entryCtrl.forward();

    // Pindah halaman setelah 3 detik
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final auth = ref.read(appAuthProvider);
      if (auth.status == AuthStatus.unauthenticated) {
        context.go(AppRoutes.onboarding);
      } else if (auth.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _loopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo: fade + membal (masuk) lalu napas + muter (looping)
            FadeTransition(
              opacity: _entryFade,
              child: AnimatedBuilder(
                animation: Listenable.merge([_entryCtrl, _loopCtrl]),
                builder: (context, child) {
                  final currentScale = _entryScale.value * _pulseScale.value;
                  return Transform.scale(
                    scale: currentScale,
                    child: Transform.rotate(
                      angle: _loopCtrl.value * 2 * math.pi,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: 240,
                  height: 240,
                ),
              ),
            ),
            const SizedBox(height: 32), // jarak dekat ke teks
            FadeTransition(
              opacity: _entryFade,
              child: const Text(
                'PinjamAja',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeTransition(
              opacity: _entryFade,
              child: const Text(
                'Pinjam apa aja, kapan aja!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}