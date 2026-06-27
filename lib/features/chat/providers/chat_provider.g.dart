// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'7be44bfa54e1aa68af8c87f510e7eaaad30deefa';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = Provider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChatRepositoryRef = ProviderRef<ChatRepository>;
String _$chatControllerHash() => r'5c30a2bc98c6c35118250dbf2ada81fd29686304';

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

abstract class _$ChatController
    extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final String bookingId;

  FutureOr<List<Message>> build(
    String bookingId,
  );
}

/// State pesan untuk satu booking + subscription realtime.
///
/// Copied from [ChatController].
@ProviderFor(ChatController)
const chatControllerProvider = ChatControllerFamily();

/// State pesan untuk satu booking + subscription realtime.
///
/// Copied from [ChatController].
class ChatControllerFamily extends Family<AsyncValue<List<Message>>> {
  /// State pesan untuk satu booking + subscription realtime.
  ///
  /// Copied from [ChatController].
  const ChatControllerFamily();

  /// State pesan untuk satu booking + subscription realtime.
  ///
  /// Copied from [ChatController].
  ChatControllerProvider call(
    String bookingId,
  ) {
    return ChatControllerProvider(
      bookingId,
    );
  }

  @override
  ChatControllerProvider getProviderOverride(
    covariant ChatControllerProvider provider,
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
  String? get name => r'chatControllerProvider';
}

/// State pesan untuk satu booking + subscription realtime.
///
/// Copied from [ChatController].
class ChatControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChatController, List<Message>> {
  /// State pesan untuk satu booking + subscription realtime.
  ///
  /// Copied from [ChatController].
  ChatControllerProvider(
    String bookingId,
  ) : this._internal(
          () => ChatController()..bookingId = bookingId,
          from: chatControllerProvider,
          name: r'chatControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatControllerHash,
          dependencies: ChatControllerFamily._dependencies,
          allTransitiveDependencies:
              ChatControllerFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  ChatControllerProvider._internal(
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
  FutureOr<List<Message>> runNotifierBuild(
    covariant ChatController notifier,
  ) {
    return notifier.build(
      bookingId,
    );
  }

  @override
  Override overrideWith(ChatController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatControllerProvider._internal(
        () => create()..bookingId = bookingId,
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
  AutoDisposeAsyncNotifierProviderElement<ChatController, List<Message>>
      createElement() {
    return _ChatControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatControllerRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _ChatControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatController,
        List<Message>> with ChatControllerRef {
  _ChatControllerProviderElement(super.provider);

  @override
  String get bookingId => (origin as ChatControllerProvider).bookingId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
