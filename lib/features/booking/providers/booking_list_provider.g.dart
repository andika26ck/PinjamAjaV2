// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$renterBookingsHash() => r'09be5462110eef75d9c824d77cefd69e8515c377';

/// Stream booking milik penyewa (real-time) + info item.
///
/// Copied from [renterBookings].
@ProviderFor(renterBookings)
final renterBookingsProvider =
    AutoDisposeStreamProvider<List<BookingView>>.internal(
  renterBookings,
  name: r'renterBookingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$renterBookingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RenterBookingsRef = AutoDisposeStreamProviderRef<List<BookingView>>;
String _$ownerBookingsHash() => r'af9d97ee481ffbbeb96c42c215731400919b8ea9';

/// Stream booking pada barang milik owner (real-time) + info item.
///
/// Copied from [ownerBookings].
@ProviderFor(ownerBookings)
final ownerBookingsProvider =
    AutoDisposeStreamProvider<List<BookingView>>.internal(
  ownerBookings,
  name: r'ownerBookingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ownerBookingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OwnerBookingsRef = AutoDisposeStreamProviderRef<List<BookingView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
