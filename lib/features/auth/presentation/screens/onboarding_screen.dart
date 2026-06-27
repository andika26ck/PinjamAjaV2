import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingData(this.icon, this.title, this.subtitle);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardingData(
      Icons.search_rounded,
      'Sewa Apa Saja',
      'Temukan ribuan barang yang bisa kamu sewa di sekitarmu dengan harga terjangkau.',
    ),
    _OnboardingData(
      Icons.storefront_rounded,
      'Daftar Barangmu',
      'Punya barang menganggur? Sewakan dan dapatkan penghasilan tambahan.',
    ),
    _OnboardingData(
      Icons.verified_user_rounded,
      'Transaksi Aman',
      'Sistem deposit & ulasan membuat setiap transaksi nyaman dan terpercaya.',
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  void _next() {
    if (_isLast) {
      context.go(AppRoutes.register);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon,
                              size: 72, color: AppColors.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 24 : 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_isLast ? 'Mulai Sekarang' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}