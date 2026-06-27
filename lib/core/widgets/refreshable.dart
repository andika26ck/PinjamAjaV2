import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension agar mudah me-refresh banyak provider sekaligus dari UI.
extension RefreshableRef on WidgetRef {
  /// Invalidate semua provider yang diberikan, lalu beri jeda singkat
  /// agar indikator RefreshIndicator sempat tampil.
  Future<void> refreshProviders(List<ProviderOrFamily> providers) async {
    for (final p in providers) {
      invalidate(p);
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}

/// Pembungkus universal untuk layar berbasis ListView/GridView.
/// `child` HARUS scrollable (atau memakai AlwaysScrollableScrollPhysics)
/// agar pull-to-refresh tetap bekerja walau konten sedikit.
class Refreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const Refreshable({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}