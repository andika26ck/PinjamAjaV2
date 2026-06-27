// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRepositoryHash() => r'de19b16895a468185a04d5a6686548de9512f2e8';

/// See also [homeRepository].
@ProviderFor(homeRepository)
final homeRepositoryProvider = Provider<HomeRepository>.internal(
  homeRepository,
  name: r'homeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeRepositoryRef = ProviderRef<HomeRepository>;
String _$categoriesHash() => r'afec1f37fa7c184f8c68a15e3158601257e06d7f';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeFutureProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$nearbyItemsHash() => r'451d0f8f51aa56aaf749717a8888fd57ccafb789';

/// See also [nearbyItems].
@ProviderFor(nearbyItems)
final nearbyItemsProvider = AutoDisposeFutureProvider<List<Item>>.internal(
  nearbyItems,
  name: r'nearbyItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nearbyItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NearbyItemsRef = AutoDisposeFutureProviderRef<List<Item>>;
String _$popularItemsHash() => r'f9c7a45a45754fcaf1d5784ae756aaf1b949df27';

/// See also [popularItems].
@ProviderFor(popularItems)
final popularItemsProvider = AutoDisposeFutureProvider<List<Item>>.internal(
  popularItems,
  name: r'popularItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$popularItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PopularItemsRef = AutoDisposeFutureProviderRef<List<Item>>;
String _$homeFilterControllerHash() =>
    r'75cfca68f48e54422e9bfc6bd203dfd38939b5f5';

/// See also [HomeFilterController].
@ProviderFor(HomeFilterController)
final homeFilterControllerProvider =
    AutoDisposeNotifierProvider<HomeFilterController, HomeFilter>.internal(
  HomeFilterController.new,
  name: r'homeFilterControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeFilterControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeFilterController = AutoDisposeNotifier<HomeFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
