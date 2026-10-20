// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDashboardStatsHash() =>
    r'cf09fddd2eaade8751eafc636b2d91da65208cd3';

/// Statistik ringkas untuk dashboard.
///
/// Copied from [adminDashboardStats].
@ProviderFor(adminDashboardStats)
final adminDashboardStatsProvider =
    AutoDisposeFutureProvider<AdminDashboardStats>.internal(
  adminDashboardStats,
  name: r'adminDashboardStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminDashboardStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminDashboardStatsRef
    = AutoDisposeFutureProviderRef<AdminDashboardStats>;
String _$adminUsersHash() => r'149e5ed80b8e3cabb8386eb95c31e934ae67d3de';

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

/// Daftar user (opsional: cari + hanya yang disuspend).
///
/// Copied from [adminUsers].
@ProviderFor(adminUsers)
const adminUsersProvider = AdminUsersFamily();

/// Daftar user (opsional: cari + hanya yang disuspend).
///
/// Copied from [adminUsers].
class AdminUsersFamily extends Family<AsyncValue<List<UserProfile>>> {
  /// Daftar user (opsional: cari + hanya yang disuspend).
  ///
  /// Copied from [adminUsers].
  const AdminUsersFamily();

  /// Daftar user (opsional: cari + hanya yang disuspend).
  ///
  /// Copied from [adminUsers].
  AdminUsersProvider call({
    String? query,
    bool? suspendedOnly,
  }) {
    return AdminUsersProvider(
      query: query,
      suspendedOnly: suspendedOnly,
    );
  }

  @override
  AdminUsersProvider getProviderOverride(
    covariant AdminUsersProvider provider,
  ) {
    return call(
      query: provider.query,
      suspendedOnly: provider.suspendedOnly,
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
  String? get name => r'adminUsersProvider';
}

/// Daftar user (opsional: cari + hanya yang disuspend).
///
/// Copied from [adminUsers].
class AdminUsersProvider extends AutoDisposeFutureProvider<List<UserProfile>> {
  /// Daftar user (opsional: cari + hanya yang disuspend).
  ///
  /// Copied from [adminUsers].
  AdminUsersProvider({
    String? query,
    bool? suspendedOnly,
  }) : this._internal(
          (ref) => adminUsers(
            ref as AdminUsersRef,
            query: query,
            suspendedOnly: suspendedOnly,
          ),
          from: adminUsersProvider,
          name: r'adminUsersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminUsersHash,
          dependencies: AdminUsersFamily._dependencies,
          allTransitiveDependencies:
              AdminUsersFamily._allTransitiveDependencies,
          query: query,
          suspendedOnly: suspendedOnly,
        );

  AdminUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.suspendedOnly,
  }) : super.internal();

  final String? query;
  final bool? suspendedOnly;

  @override
  Override overrideWith(
    FutureOr<List<UserProfile>> Function(AdminUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminUsersProvider._internal(
        (ref) => create(ref as AdminUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        suspendedOnly: suspendedOnly,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserProfile>> createElement() {
    return _AdminUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUsersProvider &&
        other.query == query &&
        other.suspendedOnly == suspendedOnly;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, suspendedOnly.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AdminUsersRef on AutoDisposeFutureProviderRef<List<UserProfile>> {
  /// The parameter `query` of this provider.
  String? get query;

  /// The parameter `suspendedOnly` of this provider.
  bool? get suspendedOnly;
}

class _AdminUsersProviderElement
    extends AutoDisposeFutureProviderElement<List<UserProfile>>
    with AdminUsersRef {
  _AdminUsersProviderElement(super.provider);

  @override
  String? get query => (origin as AdminUsersProvider).query;
  @override
  bool? get suspendedOnly => (origin as AdminUsersProvider).suspendedOnly;
}

String _$adminKycQueueHash() => r'831d8b84348e205349966bb9e2ac09b88608d946';

/// Antrian KYC menunggu review.
///
/// Copied from [adminKycQueue].
@ProviderFor(adminKycQueue)
final adminKycQueueProvider =
    AutoDisposeFutureProvider<List<UserProfile>>.internal(
  adminKycQueue,
  name: r'adminKycQueueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminKycQueueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminKycQueueRef = AutoDisposeFutureProviderRef<List<UserProfile>>;
String _$adminModerationItemsHash() =>
    r'e43062f840d66c0a344b8f01cd11a079d76429b1';

/// Item untuk moderasi (opsional filter: ok | flagged | removed).
///
/// Copied from [adminModerationItems].
@ProviderFor(adminModerationItems)
const adminModerationItemsProvider = AdminModerationItemsFamily();

/// Item untuk moderasi (opsional filter: ok | flagged | removed).
///
/// Copied from [adminModerationItems].
class AdminModerationItemsFamily extends Family<AsyncValue<List<Item>>> {
  /// Item untuk moderasi (opsional filter: ok | flagged | removed).
  ///
  /// Copied from [adminModerationItems].
  const AdminModerationItemsFamily();

  /// Item untuk moderasi (opsional filter: ok | flagged | removed).
  ///
  /// Copied from [adminModerationItems].
  AdminModerationItemsProvider call({
    String? moderationStatus,
  }) {
    return AdminModerationItemsProvider(
      moderationStatus: moderationStatus,
    );
  }

  @override
  AdminModerationItemsProvider getProviderOverride(
    covariant AdminModerationItemsProvider provider,
  ) {
    return call(
      moderationStatus: provider.moderationStatus,
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
  String? get name => r'adminModerationItemsProvider';
}

/// Item untuk moderasi (opsional filter: ok | flagged | removed).
///
/// Copied from [adminModerationItems].
class AdminModerationItemsProvider
    extends AutoDisposeFutureProvider<List<Item>> {
  /// Item untuk moderasi (opsional filter: ok | flagged | removed).
  ///
  /// Copied from [adminModerationItems].
  AdminModerationItemsProvider({
    String? moderationStatus,
  }) : this._internal(
          (ref) => adminModerationItems(
            ref as AdminModerationItemsRef,
            moderationStatus: moderationStatus,
          ),
          from: adminModerationItemsProvider,
          name: r'adminModerationItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminModerationItemsHash,
          dependencies: AdminModerationItemsFamily._dependencies,
          allTransitiveDependencies:
              AdminModerationItemsFamily._allTransitiveDependencies,
          moderationStatus: moderationStatus,
        );

  AdminModerationItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.moderationStatus,
  }) : super.internal();

  final String? moderationStatus;

  @override
  Override overrideWith(
    FutureOr<List<Item>> Function(AdminModerationItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminModerationItemsProvider._internal(
        (ref) => create(ref as AdminModerationItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        moderationStatus: moderationStatus,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Item>> createElement() {
    return _AdminModerationItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminModerationItemsProvider &&
        other.moderationStatus == moderationStatus;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, moderationStatus.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AdminModerationItemsRef on AutoDisposeFutureProviderRef<List<Item>> {
  /// The parameter `moderationStatus` of this provider.
  String? get moderationStatus;
}

class _AdminModerationItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<Item>>
    with AdminModerationItemsRef {
  _AdminModerationItemsProviderElement(super.provider);

  @override
  String? get moderationStatus =>
      (origin as AdminModerationItemsProvider).moderationStatus;
}

String _$adminReportsHash() => r'8b25ce686c1a592c973e1ffbb30bb4071dc31f49';

/// Laporan (opsional filter status).
///
/// Copied from [adminReports].
@ProviderFor(adminReports)
const adminReportsProvider = AdminReportsFamily();

/// Laporan (opsional filter status).
///
/// Copied from [adminReports].
class AdminReportsFamily extends Family<AsyncValue<List<Report>>> {
  /// Laporan (opsional filter status).
  ///
  /// Copied from [adminReports].
  const AdminReportsFamily();

  /// Laporan (opsional filter status).
  ///
  /// Copied from [adminReports].
  AdminReportsProvider call({
    String? status,
  }) {
    return AdminReportsProvider(
      status: status,
    );
  }

  @override
  AdminReportsProvider getProviderOverride(
    covariant AdminReportsProvider provider,
  ) {
    return call(
      status: provider.status,
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
  String? get name => r'adminReportsProvider';
}

/// Laporan (opsional filter status).
///
/// Copied from [adminReports].
class AdminReportsProvider extends AutoDisposeFutureProvider<List<Report>> {
  /// Laporan (opsional filter status).
  ///
  /// Copied from [adminReports].
  AdminReportsProvider({
    String? status,
  }) : this._internal(
          (ref) => adminReports(
            ref as AdminReportsRef,
            status: status,
          ),
          from: adminReportsProvider,
          name: r'adminReportsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminReportsHash,
          dependencies: AdminReportsFamily._dependencies,
          allTransitiveDependencies:
              AdminReportsFamily._allTransitiveDependencies,
          status: status,
        );

  AdminReportsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<Report>> Function(AdminReportsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminReportsProvider._internal(
        (ref) => create(ref as AdminReportsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Report>> createElement() {
    return _AdminReportsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminReportsProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AdminReportsRef on AutoDisposeFutureProviderRef<List<Report>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _AdminReportsProviderElement
    extends AutoDisposeFutureProviderElement<List<Report>>
    with AdminReportsRef {
  _AdminReportsProviderElement(super.provider);

  @override
  String? get status => (origin as AdminReportsProvider).status;
}

String _$adminDisputesHash() => r'41f8b7335291a15f53d86ba151b2d4a5140dc631';

/// Sengketa (opsional filter status).
///
/// Copied from [adminDisputes].
@ProviderFor(adminDisputes)
const adminDisputesProvider = AdminDisputesFamily();

/// Sengketa (opsional filter status).
///
/// Copied from [adminDisputes].
class AdminDisputesFamily extends Family<AsyncValue<List<Dispute>>> {
  /// Sengketa (opsional filter status).
  ///
  /// Copied from [adminDisputes].
  const AdminDisputesFamily();

  /// Sengketa (opsional filter status).
  ///
  /// Copied from [adminDisputes].
  AdminDisputesProvider call({
    String? status,
  }) {
    return AdminDisputesProvider(
      status: status,
    );
  }

  @override
  AdminDisputesProvider getProviderOverride(
    covariant AdminDisputesProvider provider,
  ) {
    return call(
      status: provider.status,
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
  String? get name => r'adminDisputesProvider';
}

/// Sengketa (opsional filter status).
///
/// Copied from [adminDisputes].
class AdminDisputesProvider extends AutoDisposeFutureProvider<List<Dispute>> {
  /// Sengketa (opsional filter status).
  ///
  /// Copied from [adminDisputes].
  AdminDisputesProvider({
    String? status,
  }) : this._internal(
          (ref) => adminDisputes(
            ref as AdminDisputesRef,
            status: status,
          ),
          from: adminDisputesProvider,
          name: r'adminDisputesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminDisputesHash,
          dependencies: AdminDisputesFamily._dependencies,
          allTransitiveDependencies:
              AdminDisputesFamily._allTransitiveDependencies,
          status: status,
        );

  AdminDisputesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<Dispute>> Function(AdminDisputesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminDisputesProvider._internal(
        (ref) => create(ref as AdminDisputesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Dispute>> createElement() {
    return _AdminDisputesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDisputesProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AdminDisputesRef on AutoDisposeFutureProviderRef<List<Dispute>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _AdminDisputesProviderElement
    extends AutoDisposeFutureProviderElement<List<Dispute>>
    with AdminDisputesRef {
  _AdminDisputesProviderElement(super.provider);

  @override
  String? get status => (origin as AdminDisputesProvider).status;
}

String _$adminPayoutsHash() => r'07250df96b75357fad3e0f41445899b7758844ee';

/// Payout / escrow (opsional filter status).
///
/// Copied from [adminPayouts].
@ProviderFor(adminPayouts)
const adminPayoutsProvider = AdminPayoutsFamily();

/// Payout / escrow (opsional filter status).
///
/// Copied from [adminPayouts].
class AdminPayoutsFamily extends Family<AsyncValue<List<Payout>>> {
  /// Payout / escrow (opsional filter status).
  ///
  /// Copied from [adminPayouts].
  const AdminPayoutsFamily();

  /// Payout / escrow (opsional filter status).
  ///
  /// Copied from [adminPayouts].
  AdminPayoutsProvider call({
    String? status,
  }) {
    return AdminPayoutsProvider(
      status: status,
    );
  }

  @override
  AdminPayoutsProvider getProviderOverride(
    covariant AdminPayoutsProvider provider,
  ) {
    return call(
      status: provider.status,
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
  String? get name => r'adminPayoutsProvider';
}

/// Payout / escrow (opsional filter status).
///
/// Copied from [adminPayouts].
class AdminPayoutsProvider extends AutoDisposeFutureProvider<List<Payout>> {
  /// Payout / escrow (opsional filter status).
  ///
  /// Copied from [adminPayouts].
  AdminPayoutsProvider({
    String? status,
  }) : this._internal(
          (ref) => adminPayouts(
            ref as AdminPayoutsRef,
            status: status,
          ),
          from: adminPayoutsProvider,
          name: r'adminPayoutsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminPayoutsHash,
          dependencies: AdminPayoutsFamily._dependencies,
          allTransitiveDependencies:
              AdminPayoutsFamily._allTransitiveDependencies,
          status: status,
        );

  AdminPayoutsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<Payout>> Function(AdminPayoutsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminPayoutsProvider._internal(
        (ref) => create(ref as AdminPayoutsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Payout>> createElement() {
    return _AdminPayoutsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminPayoutsProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AdminPayoutsRef on AutoDisposeFutureProviderRef<List<Payout>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _AdminPayoutsProviderElement
    extends AutoDisposeFutureProviderElement<List<Payout>>
    with AdminPayoutsRef {
  _AdminPayoutsProviderElement(super.provider);

  @override
  String? get status => (origin as AdminPayoutsProvider).status;
}

String _$adminConfigHash() => r'66d341d4399458d57dd44119ea122248e0f3a26e';

/// Konfigurasi platform (key -> value).
///
/// Copied from [adminConfig].
@ProviderFor(adminConfig)
final adminConfigProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  adminConfig,
  name: r'adminConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminConfigRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
