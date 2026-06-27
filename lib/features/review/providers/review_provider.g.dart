// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewRepositoryHash() => r'ff679adda86e041ac1409f5bc0479a13c4da1eb4';

/// See also [reviewRepository].
@ProviderFor(reviewRepository)
final reviewRepositoryProvider = Provider<ReviewRepository>.internal(
  reviewRepository,
  name: r'reviewRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReviewRepositoryRef = ProviderRef<ReviewRepository>;
String _$itemReviewsHash() => r'3bfb4b5809c5a95776c685a6fbfda812fde08428';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
///
/// Copied from [itemReviews].
@ProviderFor(itemReviews)
const itemReviewsProvider = ItemReviewsFamily();

/// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
///
/// Copied from [itemReviews].
class ItemReviewsFamily extends Family<AsyncValue<List<ReviewWithAuthor>>> {
  /// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
  ///
  /// Copied from [itemReviews].
  const ItemReviewsFamily();

  /// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
  ///
  /// Copied from [itemReviews].
  ItemReviewsProvider call(
    String itemId,
  ) {
    return ItemReviewsProvider(
      itemId,
    );
  }

  @override
  ItemReviewsProvider getProviderOverride(
    covariant ItemReviewsProvider provider,
  ) {
    return call(
      provider.itemId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemReviewsProvider';
}

/// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
///
/// Copied from [itemReviews].
class ItemReviewsProvider
    extends AutoDisposeFutureProvider<List<ReviewWithAuthor>> {
  /// Daftar ulasan untuk satu item (auto-refresh saat di-invalidate).
  ///
  /// Copied from [itemReviews].
  ItemReviewsProvider(
    String itemId,
  ) : this._internal(
          (ref) => itemReviews(
            ref as ItemReviewsRef,
            itemId,
          ),
          from: itemReviewsProvider,
          name: r'itemReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemReviewsHash,
          dependencies: ItemReviewsFamily._dependencies,
          allTransitiveDependencies:
              ItemReviewsFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Override overrideWith(
    FutureOr<List<ReviewWithAuthor>> Function(ItemReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemReviewsProvider._internal(
        (ref) => create(ref as ItemReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ReviewWithAuthor>> createElement() {
    return _ItemReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemReviewsProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemReviewsRef on AutoDisposeFutureProviderRef<List<ReviewWithAuthor>> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemReviewsProviderElement
    extends AutoDisposeFutureProviderElement<List<ReviewWithAuthor>>
    with ItemReviewsRef {
  _ItemReviewsProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemReviewsProvider).itemId;
}

String _$bookingReviewedHash() => r'8829a2af4f279cf9066b553ed9fcd51736a60d34';

/// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
/// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
///
/// Copied from [bookingReviewed].
@ProviderFor(bookingReviewed)
const bookingReviewedProvider = BookingReviewedFamily();

/// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
/// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
///
/// Copied from [bookingReviewed].
class BookingReviewedFamily extends Family<AsyncValue<bool>> {
  /// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
  /// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
  ///
  /// Copied from [bookingReviewed].
  const BookingReviewedFamily();

  /// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
  /// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
  ///
  /// Copied from [bookingReviewed].
  BookingReviewedProvider call(
    String bookingId,
  ) {
    return BookingReviewedProvider(
      bookingId,
    );
  }

  @override
  BookingReviewedProvider getProviderOverride(
    covariant BookingReviewedProvider provider,
  ) {
    return call(
      provider.bookingId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookingReviewedProvider';
}

/// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
/// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
///
/// Copied from [bookingReviewed].
class BookingReviewedProvider extends AutoDisposeFutureProvider<bool> {
  /// Apakah booking ini sudah pernah diulas? Dipakai BookingDetailScreen
  /// untuk menampilkan / menyembunyikan tombol “Beri Ulasan”.
  ///
  /// Copied from [bookingReviewed].
  BookingReviewedProvider(
    String bookingId,
  ) : this._internal(
          (ref) => bookingReviewed(
            ref as BookingReviewedRef,
            bookingId,
          ),
          from: bookingReviewedProvider,
          name: r'bookingReviewedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookingReviewedHash,
          dependencies: BookingReviewedFamily._dependencies,
          allTransitiveDependencies:
              BookingReviewedFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  BookingReviewedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookingId,
  }) : super.internal();

  final String bookingId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(BookingReviewedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookingReviewedProvider._internal(
        (ref) => create(ref as BookingReviewedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _BookingReviewedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingReviewedProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookingReviewedRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _BookingReviewedProviderElement
    extends AutoDisposeFutureProviderElement<bool> with BookingReviewedRef {
  _BookingReviewedProviderElement(super.provider);

  @override
  String get bookingId => (origin as BookingReviewedProvider).bookingId;
}

String _$reviewControllerHash() => r'583fde226756a99602824547a444cbe6b593bc69';

/// Controller untuk submit ulasan.
///
/// Copied from [ReviewController].
@ProviderFor(ReviewController)
final reviewControllerProvider =
    AutoDisposeAsyncNotifierProvider<ReviewController, void>.internal(
  ReviewController.new,
  name: r'reviewControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReviewController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
