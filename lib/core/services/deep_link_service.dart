import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

/// Menangkap deep link `pinjamaja://...` dan mengarahkan GoRouter.
class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();

  /// Panggil sekali setelah router siap (mis. di main / app init).
  Future<void> init() async {
    // 1) Link saat app dibuka dari keadaan mati (cold start).
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _handle(initial);
    }
    // 2) Link saat app sudah berjalan (warm).
    _appLinks.uriLinkStream.listen(_handle);
  }

  void _handle(Uri uri) {
    final location = mapUriToLocation(uri);
    if (location != null) {
      _router.push(location);
    }
  }

  /// pinjamaja://item/{id} | pinjamaja://booking/{id} | pinjamaja://chat/{bookingId}
  static String? mapUriToLocation(Uri uri) {
    final host = uri.host;
    final seg = uri.pathSegments;
    final id = seg.isNotEmpty ? seg.first : null;
    if (id == null || id.isEmpty) return null;
    switch (host) {
      case 'item':
        return AppRoutes.itemDetailPath(id);
      case 'booking':
        return AppRoutes.bookingDetailPath(id);
      case 'chat':
        return AppRoutes.chatRoomPath(id);
    }
    return null;
  }
}