import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/app_theme.dart';

class PinjamAjaApp extends ConsumerStatefulWidget {
  const PinjamAjaApp({super.key});

  @override
  ConsumerState<PinjamAjaApp> createState() => _PinjamAjaAppState();
}

class _PinjamAjaAppState extends ConsumerState<PinjamAjaApp> {
  StreamSubscription<AuthState>? _recoverySub;

  @override
  void initState() {
    super.initState();
    // Aktifkan penanganan deep link `pinjamaja://...` setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(goRouterProvider);
      DeepLinkService(router).init();
      // Alur "Lupa Password": saat tautan reset dari email dibuka, Supabase
      // memunculkan event passwordRecovery. Arahkan ke layar atur sandi baru.
      _recoverySub =
          Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery && mounted) {
          router.go(AppRoutes.resetPassword);
        }
      });
    });
  }

  @override
  void dispose() {
    _recoverySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}