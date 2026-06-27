import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../providers/payment_provider.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String snapToken;
  const PaymentWebViewScreen({
    super.key,
    required this.bookingId,
    required this.snapToken,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final url = '${AppConfig.midtransSnapUrl}/${widget.snapToken}';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith('pinjamaja://payment')) {
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _go(String location) {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.pushReplacement(location);
  }

  void _handleCallback(String url) {
    if (url.contains('/finish')) {
      _go(AppRoutes.paymentSuccessPath(widget.bookingId));
    } else if (url.contains('/pending')) {
      _go(AppRoutes.paymentPendingPath(widget.bookingId));
    } else {
      _go(AppRoutes.paymentFailedPath(widget.bookingId));
    }
  }

  Future<bool> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pembayaran?'),
        content: const Text(
            'Pembayaran belum selesai. Kamu bisa melanjutkannya lagi nanti.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Lanjut Bayar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Webhook bisa lebih cepat dari redirect: pindah begitu status final.
    ref.listen(paymentByBookingProvider(widget.bookingId), (_, next) {
      final p = next.valueOrNull;
      if (p == null) return;
      if (p.isPaid) {
        _go(AppRoutes.paymentSuccessPath(widget.bookingId));
      } else if (p.status == PaymentStatusType.failed ||
          p.status == PaymentStatusType.expired) {
        _go(AppRoutes.paymentFailedPath(widget.bookingId));
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran'),
          bottom: _loading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              : null,
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}