// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAdminHash() => r'ed2d602345ec320f24c1024b22ab8850133b4252';

/// True bila user yang sedang login adalah admin.
///
/// Copied from [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = AutoDisposeProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAdminRef = AutoDisposeProviderRef<bool>;
String _$isSuspendedHash() => r'e9036dfc56c8b94256b71fa4c25e18c8eab66ac7';

/// True bila akun user sedang dibekukan (suspended).
///
/// Copied from [isSuspended].
@ProviderFor(isSuspended)
final isSuspendedProvider = AutoDisposeProvider<bool>.internal(
  isSuspended,
  name: r'isSuspendedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isSuspendedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsSuspendedRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
