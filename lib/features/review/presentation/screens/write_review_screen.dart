import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_exception.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/item.dart';
import '../../providers/review_provider.dart';
import '../widgets/star_rating_input.dart';

/// Dibuka dari BookingDetailScreen ketika status booking = completed
/// dan booking belum diulas. Membutuhkan info booking + item.
class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({
    super.key,
    required this.bookingId,
    required this.item,
  });

  final String bookingId;
  final Item item;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  static const int _minChars = 20;
  static const int _maxChars = 500;

  final _commentCtrl = TextEditingController();
  int _rating = 0;
  bool _attempted = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String? get _commentError {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return 'Komentar wajib diisi.';
    if (text.length < _minChars) {
      return 'Komentar minimal $_minChars karakter (saat ini ${text.length}).';
    }
    return null;
  }

  bool get _isValid => _rating > 0 && _commentError == null;

  Future<void> _submit() async {
    setState(() => _attempted = true);
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jumlah bintang dulu ya.')),
      );
      return;
    }
    if (!_isValid) return;

    final ok = await ref.read(reviewControllerProvider.notifier).submit(
          bookingId: widget.bookingId,
          itemId: widget.item.id,
          rating: _rating,
          comment: _commentCtrl.text,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih! Ulasan kamu terkirim.')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewControllerProvider);
    final busy = state.isLoading;

    // Tampilkan error dari controller via SnackBar.
    ref.listen(reviewControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        final msg = next.error is AppException
            ? (next.error as AppException).message
            : 'Gagal mengirim ulasan. Coba lagi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    });

    final thumb = widget.item.thumbnailUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Beri Ulasan')),
      body: AbsorbPointer(
        absorbing: busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info barang.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: (thumb != null && thumb.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: thumb,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const ColoredBox(color: AppColors.border),
                            )
                          : const ColoredBox(
                              color: AppColors.border,
                              child: Icon(Icons.inventory_2_outlined),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating bintang.
            const Center(
              child: Text(
                'Seberapa puas kamu?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            StarRatingInput(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _ratingLabel(_rating),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Komentar.
            TextField(
              controller: _commentCtrl,
              minLines: 4,
              maxLines: 8,
              maxLength: _maxChars,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Ceritakan pengalamanmu',
                hintText: 'Minimal $_minChars karakter…',
                alignLabelWithHint: true,
                errorText: _attempted ? _commentError : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: busy ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kirim Ulasan'),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Sangat buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Bagus';
      case 5:
        return 'Sangat bagus';
      default:
        return 'Ketuk bintang untuk menilai';
    }
  }
}