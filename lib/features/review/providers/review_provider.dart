import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../../items/providers/item_detail_provider.dart';
import '../data/review_repository.dart';
import '../data/supabase_review_repository.dart';

part 'review_provider.g.dart';

@Riverpod(keepAlive: true)
ReviewRepository reviewRepository(ReviewRepositoryRef ref) {
  return SupabaseReviewRepository(ref.watch(supabaseClientProvider));
}

/// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
@riverpod
Future<List<ReviewWithAuthor>> itemReviews(
  ItemReviewsRef ref,
  String itemId,
) {
  return ref.watch(reviewRepositoryProvider).fetchItemReviews(itemId);
}

/// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
/// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
@riverpod
Future<bool> bookingReviewed(BookingReviewedRef ref, String bookingId) {
  return ref.watch(reviewRepositoryProvider).hasReviewed(bookingId);
}

/// Controller untuk submit ulasan.
@riverpod
class ReviewController extends _$ReviewController {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required String bookingId,
    required String itemId,
    required int rating,
    required String comment,
  }) async {
    final auth = ref.read(appAuthProvider);
    final uid = auth.profile?.id;
    if (uid == null) {
      state = AsyncError(
        const AppException('Sesi berakhir. Silakan masuk kembali.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(reviewRepositoryProvider).submitReview(
            bookingId: bookingId,
            itemId: itemId,
            reviewerId: uid,
            rating: rating,
            comment: comment,
          );
    });

    state = result;
    if (result.hasError) return false;

    // Segarkan data terkait: detail item, daftar ulasan, status booking diulas.
    ref.invalidate(itemDetailProvider(itemId));
    ref.invalidate(itemReviewsProvider(itemId));
    ref.invalidate(bookingReviewedProvider(bookingId));
    return true;
  }
}