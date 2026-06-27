// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistRepositoryHash() =>
    r'f98781e7e7914b6383fbfb5a040a0dd05b30ade8';

/// See also [wishlistRepository].
@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider = Provider<WishlistRepository>.internal(
  wishlistRepository,
  name: r'wishlistRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WishlistRepositoryRef = ProviderRef<WishlistRepository>;
String _$isWishlistedHash() => r'773058ade88caf3a3e2a90e9769ae572d1ed18a6';

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

/// Cek cepat apakah sebuah item sudah di-wishlist.
///
/// Copied from [isWishlisted].
@ProviderFor(isWishlisted)
const isWishlistedProvider = IsWishlistedFamily();

/// Cek cepat apakah sebuah item sudah di-wishlist.
///
/// Copied from [isWishlisted].
class IsWishlistedFamily extends Family<bool> {
  /// Cek cepat apakah sebuah item sudah di-wishlist.
  ///
  /// Copied from [isWishlisted].
  const IsWishlistedFamily();

  /// Cek cepat apakah sebuah item sudah di-wishlist.
  ///
  /// Copied from [isWishlisted].
  IsWishlistedProvider call(
    String itemId,
  ) {
    return IsWishlistedProvider(
      itemId,
    );
  }

  @override
  IsWishlistedProvider getProviderOverride(
    covariant IsWishlistedProvider provider,
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
  String? get name => r'isWishlistedProvider';
}

/// Cek cepat apakah sebuah item sudah di-wishlist.
///
/// Copied from [isWishlisted].
class IsWishlistedProvider extends AutoDisposeProvider<bool> {
  /// Cek cepat apakah sebuah item sudah di-wishlist.
  ///
  /// Copied from [isWishlisted].
  IsWishlistedProvider(
    String itemId,
  ) : this._internal(
          (ref) => isWishlisted(
            ref as IsWishlistedRef,
            itemId,
          ),
          from: isWishlistedProvider,
          name: r'isWishlistedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isWishlistedHash,
          dependencies: IsWishlistedFamily._dependencies,
          allTransitiveDependencies:
              IsWishlistedFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  IsWishlistedProvider._internal(
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
    bool Function(IsWishlistedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsWishlistedProvider._internal(
        (ref) => create(ref as IsWishlistedRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsWishlistedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsWishlistedProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsWishlistedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _IsWishlistedProviderElement extends AutoDisposeProviderElement<bool>
    with IsWishlistedRef {
  _IsWishlistedProviderElement(super.provider);

  @override
  String get itemId => (origin as IsWishlistedProvider).itemId;
}

String _$wishlistItemsHash() => r'3afde7cd7201013f896675227ec0b52c42198e7e';

/// Daftar item lengkap yang di-wishlist (untuk layar Wishlist).
///
/// Copied from [wishlistItems].
@ProviderFor(wishlistItems)
final wishlistItemsProvider = AutoDisposeFutureProvider<List<Item>>.internal(
  wishlistItems,
  name: r'wishlistItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WishlistItemsRef = AutoDisposeFutureProviderRef<List<Item>>;
String _$wishlistIdsHash() => r'ec51bc6a7c054ade471d5aa0f8eca6935f7ca297';

/// Set id item yang di-wishlist user aktif. Mendukung optimistic update.
///
/// Copied from [WishlistIds].
@ProviderFor(WishlistIds)
final wishlistIdsProvider =
    AsyncNotifierProvider<WishlistIds, Set<String>>.internal(
  WishlistIds.new,
  name: r'wishlistIdsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$wishlistIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WishlistIds = AsyncNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
