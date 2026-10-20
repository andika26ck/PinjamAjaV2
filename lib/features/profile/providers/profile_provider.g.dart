// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'8ab26aa2884a78e39214c4cad422892dc73ef282';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider = Provider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProfileRepositoryRef = ProviderRef<ProfileRepository>;
String _$myProfileHash() => r'833af4ec700ee18fcaab0b7e2c5cf06d9b032884';

/// Profil user yang sedang login — sumber kebenaran tunggal dari state auth (Fase 1).
///
/// Copied from [myProfile].
@ProviderFor(myProfile)
final myProfileProvider = AutoDisposeProvider<UserProfile?>.internal(
  myProfile,
  name: r'myProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyProfileRef = AutoDisposeProviderRef<UserProfile?>;
String _$profileStatsHash() => r'30c45a3118a3a857e7e74f33733154ab8c55e8ff';

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

/// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
///
/// Copied from [profileStats].
@ProviderFor(profileStats)
const profileStatsProvider = ProfileStatsFamily();

/// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
///
/// Copied from [profileStats].
class ProfileStatsFamily extends Family<AsyncValue<ProfileStats>> {
  /// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
  ///
  /// Copied from [profileStats].
  const ProfileStatsFamily();

  /// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
  ///
  /// Copied from [profileStats].
  ProfileStatsProvider call(
    String userId,
  ) {
    return ProfileStatsProvider(
      userId,
    );
  }

  @override
  ProfileStatsProvider getProviderOverride(
    covariant ProfileStatsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'profileStatsProvider';
}

/// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
///
/// Copied from [profileStats].
class ProfileStatsProvider extends AutoDisposeFutureProvider<ProfileStats> {
  /// Statistik header profil sendiri (booking selesai, barang, ulasan diterima).
  ///
  /// Copied from [profileStats].
  ProfileStatsProvider(
    String userId,
  ) : this._internal(
          (ref) => profileStats(
            ref as ProfileStatsRef,
            userId,
          ),
          from: profileStatsProvider,
          name: r'profileStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileStatsHash,
          dependencies: ProfileStatsFamily._dependencies,
          allTransitiveDependencies:
              ProfileStatsFamily._allTransitiveDependencies,
          userId: userId,
        );

  ProfileStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<ProfileStats> Function(ProfileStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileStatsProvider._internal(
        (ref) => create(ref as ProfileStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProfileStats> createElement() {
    return _ProfileStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileStatsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProfileStatsRef on AutoDisposeFutureProviderRef<ProfileStats> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileStatsProviderElement
    extends AutoDisposeFutureProviderElement<ProfileStats>
    with ProfileStatsRef {
  _ProfileStatsProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileStatsProvider).userId;
}

String _$publicProfileHash() => r'426d65116fe9f35fd2871e5eeb75e198fc665c9d';

/// Data profil publik (profil + barang aktif + ulasan diterima).
///
/// Copied from [publicProfile].
@ProviderFor(publicProfile)
const publicProfileProvider = PublicProfileFamily();

/// Data profil publik (profil + barang aktif + ulasan diterima).
///
/// Copied from [publicProfile].
class PublicProfileFamily extends Family<AsyncValue<PublicProfileData>> {
  /// Data profil publik (profil + barang aktif + ulasan diterima).
  ///
  /// Copied from [publicProfile].
  const PublicProfileFamily();

  /// Data profil publik (profil + barang aktif + ulasan diterima).
  ///
  /// Copied from [publicProfile].
  PublicProfileProvider call(
    String userId,
  ) {
    return PublicProfileProvider(
      userId,
    );
  }

  @override
  PublicProfileProvider getProviderOverride(
    covariant PublicProfileProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'publicProfileProvider';
}

/// Data profil publik (profil + barang aktif + ulasan diterima).
///
/// Copied from [publicProfile].
class PublicProfileProvider
    extends AutoDisposeFutureProvider<PublicProfileData> {
  /// Data profil publik (profil + barang aktif + ulasan diterima).
  ///
  /// Copied from [publicProfile].
  PublicProfileProvider(
    String userId,
  ) : this._internal(
          (ref) => publicProfile(
            ref as PublicProfileRef,
            userId,
          ),
          from: publicProfileProvider,
          name: r'publicProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$publicProfileHash,
          dependencies: PublicProfileFamily._dependencies,
          allTransitiveDependencies:
              PublicProfileFamily._allTransitiveDependencies,
          userId: userId,
        );

  PublicProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<PublicProfileData> Function(PublicProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublicProfileProvider._internal(
        (ref) => create(ref as PublicProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PublicProfileData> createElement() {
    return _PublicProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PublicProfileRef on AutoDisposeFutureProviderRef<PublicProfileData> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PublicProfileProviderElement
    extends AutoDisposeFutureProviderElement<PublicProfileData>
    with PublicProfileRef {
  _PublicProfileProviderElement(super.provider);

  @override
  String get userId => (origin as PublicProfileProvider).userId;
}

String _$profileControllerHash() => r'7b222c08023d8e00cf22a287efa723c69ae74593';

/// Controller aksi profil. State `AsyncValue<void>` untuk loading & error.
///
/// Copied from [ProfileController].
@ProviderFor(ProfileController)
final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, void>.internal(
  ProfileController.new,
  name: r'profileControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
