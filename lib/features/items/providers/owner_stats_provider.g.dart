// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ownerItemStatsHash() => r'6439b1e7bca260f32577e42c9f3e8432b12d1664';

/// Map itemId -> statistik mini, dari satu query semua booking milik owner.
///
/// Copied from [ownerItemStats].
@ProviderFor(ownerItemStats)
final ownerItemStatsProvider =
    AutoDisposeFutureProvider<Map<String, ItemMiniStat>>.internal(
  ownerItemStats,
  name: r'ownerItemStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ownerItemStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OwnerItemStatsRef
    = AutoDisposeFutureProviderRef<Map<String, ItemMiniStat>>;
String _$itemStatsHash() => r'60f85f5244f6df42a010f4a9f80beee006a7eb20';

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

/// See also [itemStats].
@ProviderFor(itemStats)
const itemStatsProvider = ItemStatsFamily();

/// See also [itemStats].
class ItemStatsFamily extends Family<AsyncValue<ItemStatsBundle>> {
  /// See also [itemStats].
  const ItemStatsFamily();

  /// See also [itemStats].
  ItemStatsProvider call(
    String itemId,
  ) {
    return ItemStatsProvider(
      itemId,
    );
  }

  @override
  ItemStatsProvider getProviderOverride(
    covariant ItemStatsProvider provider,
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
  String? get name => r'itemStatsProvider';
}

/// See also [itemStats].
class ItemStatsProvider extends AutoDisposeFutureProvider<ItemStatsBundle> {
  /// See also [itemStats].
  ItemStatsProvider(
    String itemId,
  ) : this._internal(
          (ref) => itemStats(
            ref as ItemStatsRef,
            itemId,
          ),
          from: itemStatsProvider,
          name: r'itemStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemStatsHash,
          dependencies: ItemStatsFamily._dependencies,
          allTransitiveDependencies: ItemStatsFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemStatsProvider._internal(
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
    FutureOr<ItemStatsBundle> Function(ItemStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemStatsProvider._internal(
        (ref) => create(ref as ItemStatsRef),
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
  AutoDisposeFutureProviderElement<ItemStatsBundle> createElement() {
    return _ItemStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemStatsProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemStatsRef on AutoDisposeFutureProviderRef<ItemStatsBundle> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemStatsProviderElement
    extends AutoDisposeFutureProviderElement<ItemStatsBundle>
    with ItemStatsRef {
  _ItemStatsProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemStatsProvider).itemId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
