// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatContextHash() => r'e30669e044658e6a2d886104270b2c3f6a698656';

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

/// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
/// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
///
/// Copied from [chatContext].
@ProviderFor(chatContext)
const chatContextProvider = ChatContextFamily();

/// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
/// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
///
/// Copied from [chatContext].
class ChatContextFamily extends Family<AsyncValue<ChatContext>> {
  /// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
  /// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
  ///
  /// Copied from [chatContext].
  const ChatContextFamily();

  /// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
  /// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
  ///
  /// Copied from [chatContext].
  ChatContextProvider call(
    String itemId,
    String otherUserId,
  ) {
    return ChatContextProvider(
      itemId,
      otherUserId,
    );
  }

  @override
  ChatContextProvider getProviderOverride(
    covariant ChatContextProvider provider,
  ) {
    return call(
      provider.itemId,
      provider.otherUserId,
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
  String? get name => r'chatContextProvider';
}

/// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
/// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
///
/// Copied from [chatContext].
class ChatContextProvider extends AutoDisposeFutureProvider<ChatContext> {
  /// Konteks chat berbasis (item + lawan bicara). Booking dicari kalau ada,
  /// tapi tidak wajib — renter bisa menghubungi owner sebelum booking dibuat.
  ///
  /// Copied from [chatContext].
  ChatContextProvider(
    String itemId,
    String otherUserId,
  ) : this._internal(
          (ref) => chatContext(
            ref as ChatContextRef,
            itemId,
            otherUserId,
          ),
          from: chatContextProvider,
          name: r'chatContextProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatContextHash,
          dependencies: ChatContextFamily._dependencies,
          allTransitiveDependencies:
              ChatContextFamily._allTransitiveDependencies,
          itemId: itemId,
          otherUserId: otherUserId,
        );

  ChatContextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
    required this.otherUserId,
  }) : super.internal();

  final String itemId;
  final String otherUserId;

  @override
  Override overrideWith(
    FutureOr<ChatContext> Function(ChatContextRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatContextProvider._internal(
        (ref) => create(ref as ChatContextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatContext> createElement() {
    return _ChatContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatContextProvider &&
        other.itemId == itemId &&
        other.otherUserId == otherUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);
    hash = _SystemHash.combine(hash, otherUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatContextRef on AutoDisposeFutureProviderRef<ChatContext> {
  /// The parameter `itemId` of this provider.
  String get itemId;

  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _ChatContextProviderElement
    extends AutoDisposeFutureProviderElement<ChatContext> with ChatContextRef {
  _ChatContextProviderElement(super.provider);

  @override
  String get itemId => (origin as ChatContextProvider).itemId;
  @override
  String get otherUserId => (origin as ChatContextProvider).otherUserId;
}

String _$chatTargetFromBookingHash() =>
    r'4bde3da2923b92b2f9665cf9eeca6865e7a51f3d';

/// See also [chatTargetFromBooking].
@ProviderFor(chatTargetFromBooking)
const chatTargetFromBookingProvider = ChatTargetFromBookingFamily();

/// See also [chatTargetFromBooking].
class ChatTargetFromBookingFamily extends Family<AsyncValue<ChatTarget>> {
  /// See also [chatTargetFromBooking].
  const ChatTargetFromBookingFamily();

  /// See also [chatTargetFromBooking].
  ChatTargetFromBookingProvider call(
    String bookingId,
  ) {
    return ChatTargetFromBookingProvider(
      bookingId,
    );
  }

  @override
  ChatTargetFromBookingProvider getProviderOverride(
    covariant ChatTargetFromBookingProvider provider,
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
  String? get name => r'chatTargetFromBookingProvider';
}

/// See also [chatTargetFromBooking].
class ChatTargetFromBookingProvider
    extends AutoDisposeFutureProvider<ChatTarget> {
  /// See also [chatTargetFromBooking].
  ChatTargetFromBookingProvider(
    String bookingId,
  ) : this._internal(
          (ref) => chatTargetFromBooking(
            ref as ChatTargetFromBookingRef,
            bookingId,
          ),
          from: chatTargetFromBookingProvider,
          name: r'chatTargetFromBookingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatTargetFromBookingHash,
          dependencies: ChatTargetFromBookingFamily._dependencies,
          allTransitiveDependencies:
              ChatTargetFromBookingFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  ChatTargetFromBookingProvider._internal(
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
    FutureOr<ChatTarget> Function(ChatTargetFromBookingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatTargetFromBookingProvider._internal(
        (ref) => create(ref as ChatTargetFromBookingRef),
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
  AutoDisposeFutureProviderElement<ChatTarget> createElement() {
    return _ChatTargetFromBookingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatTargetFromBookingProvider &&
        other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatTargetFromBookingRef on AutoDisposeFutureProviderRef<ChatTarget> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _ChatTargetFromBookingProviderElement
    extends AutoDisposeFutureProviderElement<ChatTarget>
    with ChatTargetFromBookingRef {
  _ChatTargetFromBookingProviderElement(super.provider);

  @override
  String get bookingId => (origin as ChatTargetFromBookingProvider).bookingId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
