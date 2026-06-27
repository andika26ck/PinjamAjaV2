// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatContextHash() => r'154654ff6f0b046446e4b8a70456db827e31d22f';

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

/// See also [chatContext].
@ProviderFor(chatContext)
const chatContextProvider = ChatContextFamily();

/// See also [chatContext].
class ChatContextFamily extends Family<AsyncValue<ChatContext>> {
  /// See also [chatContext].
  const ChatContextFamily();

  /// See also [chatContext].
  ChatContextProvider call(
    String bookingId,
  ) {
    return ChatContextProvider(
      bookingId,
    );
  }

  @override
  ChatContextProvider getProviderOverride(
    covariant ChatContextProvider provider,
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
  String? get name => r'chatContextProvider';
}

/// See also [chatContext].
class ChatContextProvider extends AutoDisposeFutureProvider<ChatContext> {
  /// See also [chatContext].
  ChatContextProvider(
    String bookingId,
  ) : this._internal(
          (ref) => chatContext(
            ref as ChatContextRef,
            bookingId,
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
          bookingId: bookingId,
        );

  ChatContextProvider._internal(
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
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatContext> createElement() {
    return _ChatContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatContextProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatContextRef on AutoDisposeFutureProviderRef<ChatContext> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _ChatContextProviderElement
    extends AutoDisposeFutureProviderElement<ChatContext> with ChatContextRef {
  _ChatContextProviderElement(super.provider);

  @override
  String get bookingId => (origin as ChatContextProvider).bookingId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
