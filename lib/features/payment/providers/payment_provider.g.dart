// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentRepositoryHash() => r'454585998274ab1f59142b9926db9d2f2a745e02';

/// See also [paymentRepository].
@ProviderFor(paymentRepository)
final paymentRepositoryProvider = Provider<PaymentRepository>.internal(
  paymentRepository,
  name: r'paymentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PaymentRepositoryRef = ProviderRef<PaymentRepository>;
String _$createPaymentHash() => r'0e508ea1d5f819db211f0c6e9b15d39732738671';

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

/// Trigger pembuatan Snap token untuk sebuah booking.
///
/// Copied from [createPayment].
@ProviderFor(createPayment)
const createPaymentProvider = CreatePaymentFamily();

/// Trigger pembuatan Snap token untuk sebuah booking.
///
/// Copied from [createPayment].
class CreatePaymentFamily extends Family<AsyncValue<PaymentRequestModel>> {
  /// Trigger pembuatan Snap token untuk sebuah booking.
  ///
  /// Copied from [createPayment].
  const CreatePaymentFamily();

  /// Trigger pembuatan Snap token untuk sebuah booking.
  ///
  /// Copied from [createPayment].
  CreatePaymentProvider call(
    String bookingId,
  ) {
    return CreatePaymentProvider(
      bookingId,
    );
  }

  @override
  CreatePaymentProvider getProviderOverride(
    covariant CreatePaymentProvider provider,
  ) {
    return call(
      provider.bookingId,
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
  String? get name => r'createPaymentProvider';
}

/// Trigger pembuatan Snap token untuk sebuah booking.
///
/// Copied from [createPayment].
class CreatePaymentProvider
    extends AutoDisposeFutureProvider<PaymentRequestModel> {
  /// Trigger pembuatan Snap token untuk sebuah booking.
  ///
  /// Copied from [createPayment].
  CreatePaymentProvider(
    String bookingId,
  ) : this._internal(
          (ref) => createPayment(
            ref as CreatePaymentRef,
            bookingId,
          ),
          from: createPaymentProvider,
          name: r'createPaymentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createPaymentHash,
          dependencies: CreatePaymentFamily._dependencies,
          allTransitiveDependencies:
              CreatePaymentFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  CreatePaymentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookingId,
  }) : super.internal();

  final String bookingId;

  @override
  Override overrideWith(
    FutureOr<PaymentRequestModel> Function(CreatePaymentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreatePaymentProvider._internal(
        (ref) => create(ref as CreatePaymentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaymentRequestModel> createElement() {
    return _CreatePaymentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreatePaymentProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreatePaymentRef on AutoDisposeFutureProviderRef<PaymentRequestModel> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _CreatePaymentProviderElement
    extends AutoDisposeFutureProviderElement<PaymentRequestModel>
    with CreatePaymentRef {
  _CreatePaymentProviderElement(super.provider);

  @override
  String get bookingId => (origin as CreatePaymentProvider).bookingId;
}

String _$paymentByBookingHash() => r'6fc7f9948caa40f6b4214e215135fc0fb31dd127';

/// Status pembayaran realtime (auto-update via Supabase Realtime).
///
/// Copied from [paymentByBooking].
@ProviderFor(paymentByBooking)
const paymentByBookingProvider = PaymentByBookingFamily();

/// Status pembayaran realtime (auto-update via Supabase Realtime).
///
/// Copied from [paymentByBooking].
class PaymentByBookingFamily extends Family<AsyncValue<PaymentModel?>> {
  /// Status pembayaran realtime (auto-update via Supabase Realtime).
  ///
  /// Copied from [paymentByBooking].
  const PaymentByBookingFamily();

  /// Status pembayaran realtime (auto-update via Supabase Realtime).
  ///
  /// Copied from [paymentByBooking].
  PaymentByBookingProvider call(
    String bookingId,
  ) {
    return PaymentByBookingProvider(
      bookingId,
    );
  }

  @override
  PaymentByBookingProvider getProviderOverride(
    covariant PaymentByBookingProvider provider,
  ) {
    return call(
      provider.bookingId,
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
  String? get name => r'paymentByBookingProvider';
}

/// Status pembayaran realtime (auto-update via Supabase Realtime).
///
/// Copied from [paymentByBooking].
class PaymentByBookingProvider
    extends AutoDisposeStreamProvider<PaymentModel?> {
  /// Status pembayaran realtime (auto-update via Supabase Realtime).
  ///
  /// Copied from [paymentByBooking].
  PaymentByBookingProvider(
    String bookingId,
  ) : this._internal(
          (ref) => paymentByBooking(
            ref as PaymentByBookingRef,
            bookingId,
          ),
          from: paymentByBookingProvider,
          name: r'paymentByBookingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paymentByBookingHash,
          dependencies: PaymentByBookingFamily._dependencies,
          allTransitiveDependencies:
              PaymentByBookingFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  PaymentByBookingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookingId,
  }) : super.internal();

  final String bookingId;

  @override
  Override overrideWith(
    Stream<PaymentModel?> Function(PaymentByBookingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentByBookingProvider._internal(
        (ref) => create(ref as PaymentByBookingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<PaymentModel?> createElement() {
    return _PaymentByBookingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentByBookingProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PaymentByBookingRef on AutoDisposeStreamProviderRef<PaymentModel?> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _PaymentByBookingProviderElement
    extends AutoDisposeStreamProviderElement<PaymentModel?>
    with PaymentByBookingRef {
  _PaymentByBookingProviderElement(super.provider);

  @override
  String get bookingId => (origin as PaymentByBookingProvider).bookingId;
}

String _$ownerPayoutsHash() => r'aef012b66fa4e6d1dc10486df73e48ea9a9b8c89';

/// Ringkasan & daftar payout untuk owner yang login.
///
/// Copied from [ownerPayouts].
@ProviderFor(ownerPayouts)
final ownerPayoutsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  ownerPayouts,
  name: r'ownerPayoutsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ownerPayoutsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OwnerPayoutsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$refundControllerHash() => r'7fb579dda82721a5c93b9568c8e45535531f7e32';

/// Aksi refund deposit oleh owner.
///
/// Copied from [RefundController].
@ProviderFor(RefundController)
final refundControllerProvider =
    AutoDisposeAsyncNotifierProvider<RefundController, void>.internal(
  RefundController.new,
  name: r'refundControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$refundControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RefundController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
