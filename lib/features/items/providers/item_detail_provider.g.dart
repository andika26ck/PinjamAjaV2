// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemRepositoryHash() => r'd446885a9537549ef8ef7b782c522213599574de';

/// See also [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider = Provider<ItemRepository>.internal(
  itemRepository,
  name: r'itemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ItemRepositoryRef = ProviderRef<ItemRepository>;
String _$itemDetailHash() => r'782c1d203c796842d74488f132602294607013ad';

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

/// See also [itemDetail].
@ProviderFor(itemDetail)
const itemDetailProvider = ItemDetailFamily();

/// See also [itemDetail].
class ItemDetailFamily extends Family<AsyncValue<ItemDetailBundle>> {
  /// See also [itemDetail].
  const ItemDetailFamily();

  /// See also [itemDetail].
  ItemDetailProvider call(
    String itemId,
  ) {
    return ItemDetailProvider(
      itemId,
    );
  }

  @override
  ItemDetailProvider getProviderOverride(
    covariant ItemDetailProvider provider,
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
  String? get name => r'itemDetailProvider';
}

/// See also [itemDetail].
class ItemDetailProvider extends AutoDisposeFutureProvider<ItemDetailBundle> {
  /// See also [itemDetail].
  ItemDetailProvider(
    String itemId,
  ) : this._internal(
          (ref) => itemDetail(
            ref as ItemDetailRef,
            itemId,
          ),
          from: itemDetailProvider,
          name: r'itemDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemDetailHash,
          dependencies: ItemDetailFamily._dependencies,
          allTransitiveDependencies:
              ItemDetailFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemDetailProvider._internal(
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
    FutureOr<ItemDetailBundle> Function(ItemDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemDetailProvider._internal(
        (ref) => create(ref as ItemDetailRef),
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
  AutoDisposeFutureProviderElement<ItemDetailBundle> createElement() {
    return _ItemDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemDetailProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemDetailRef on AutoDisposeFutureProviderRef<ItemDetailBundle> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemDetailProviderElement
    extends AutoDisposeFutureProviderElement<ItemDetailBundle>
    with ItemDetailRef {
  _ItemDetailProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemDetailProvider).itemId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
