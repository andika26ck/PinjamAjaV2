// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingRepositoryHash() => r'029c6d21d32192426da7a7d9d379e6980cabe98e';

/// See also [bookingRepository].
@ProviderFor(bookingRepository)
final bookingRepositoryProvider = Provider<BookingRepository>.internal(
  bookingRepository,
  name: r'bookingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BookingRepositoryRef = ProviderRef<BookingRepository>;
String _$bookingItemHash() => r'25d9d8bb87db6d252faa9f5c3a44f1a378db7646';

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

/// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
///
/// Copied from [bookingItem].
@ProviderFor(bookingItem)
const bookingItemProvider = BookingItemFamily();

/// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
///
/// Copied from [bookingItem].
class BookingItemFamily extends Family<AsyncValue<Item>> {
  /// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
  ///
  /// Copied from [bookingItem].
  const BookingItemFamily();

  /// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
  ///
  /// Copied from [bookingItem].
  BookingItemProvider call(
    String itemId,
  ) {
    return BookingItemProvider(
      itemId,
    );
  }

  @override
  BookingItemProvider getProviderOverride(
    covariant BookingItemProvider provider,
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
  String? get name => r'bookingItemProvider';
}

/// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
///
/// Copied from [bookingItem].
class BookingItemProvider extends AutoDisposeFutureProvider<Item> {
  /// Ambil item untuk layar booking bila tidak dikirim lewat `extra`.
  ///
  /// Copied from [bookingItem].
  BookingItemProvider(
    String itemId,
  ) : this._internal(
          (ref) => bookingItem(
            ref as BookingItemRef,
            itemId,
          ),
          from: bookingItemProvider,
          name: r'bookingItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookingItemHash,
          dependencies: BookingItemFamily._dependencies,
          allTransitiveDependencies:
              BookingItemFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  BookingItemProvider._internal(
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
    FutureOr<Item> Function(BookingItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookingItemProvider._internal(
        (ref) => create(ref as BookingItemRef),
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
  AutoDisposeFutureProviderElement<Item> createElement() {
    return _BookingItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingItemProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookingItemRef on AutoDisposeFutureProviderRef<Item> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _BookingItemProviderElement extends AutoDisposeFutureProviderElement<Item>
    with BookingItemRef {
  _BookingItemProviderElement(super.provider);

  @override
  String get itemId => (origin as BookingItemProvider).itemId;
}

String _$bookingControllerHash() => r'4ecffbe7f2232c371b52923c5320793e610dc20c';

/// Aksi tulis booking. State `AsyncValue<void>` untuk loading & error.
///
/// Copied from [BookingController].
@ProviderFor(BookingController)
final bookingControllerProvider =
    AutoDisposeAsyncNotifierProvider<BookingController, void>.internal(
  BookingController.new,
  name: r'bookingControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
