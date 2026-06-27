// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseClientHash() => r'a423e7187c202c89ed9ab6db50e56f0695ae703d';

/// See also [supabaseClient].
@ProviderFor(supabaseClient)
final supabaseClientProvider = Provider<SupabaseClient>.internal(
  supabaseClient,
  name: r'supabaseClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SupabaseClientRef = ProviderRef<SupabaseClient>;
String _$authRepositoryHash() => r'b24c293f05994da53f99145803adb106dd602a68';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$appAuthHash() => r'2577be416d485df0b6977826adee9ef90cf10d48';

/// See also [AppAuth].
@ProviderFor(AppAuth)
final appAuthProvider = NotifierProvider<AppAuth, AppAuthState>.internal(
  AppAuth.new,
  name: r'appAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppAuth = Notifier<AppAuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
