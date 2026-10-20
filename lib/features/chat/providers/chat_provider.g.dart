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
String _$chatControllerHash() => r'e177813bb1920a503393c665fd45f5f32dc4da5c';

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
  late final String itemId;
  late final String otherUserId;

  FutureOr<List<Message>> build(
    String itemId,
    String otherUserId,
  );
}

/// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
///
/// Copied from [ChatController].
@ProviderFor(ChatController)
const chatControllerProvider = ChatControllerFamily();

/// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
///
/// Copied from [ChatController].
class ChatControllerFamily extends Family<AsyncValue<List<Message>>> {
  /// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
  ///
  /// Copied from [ChatController].
  const ChatControllerFamily();

  /// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
  ///
  /// Copied from [ChatController].
  ChatControllerProvider call(
    String itemId,
    String otherUserId,
  ) {
    return ChatControllerProvider(
      itemId,
      otherUserId,
    );
  }

  @override
  ChatControllerProvider getProviderOverride(
    covariant ChatControllerProvider provider,
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
  String? get name => r'chatControllerProvider';
}

/// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
///
/// Copied from [ChatController].
class ChatControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChatController, List<Message>> {
  /// State pesan untuk satu thread (item + lawan bicara) + subscription realtime.
  ///
  /// Copied from [ChatController].
  ChatControllerProvider(
    String itemId,
    String otherUserId,
  ) : this._internal(
          () => ChatController()
            ..itemId = itemId
            ..otherUserId = otherUserId,
          from: chatControllerProvider,
          name: r'chatControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatControllerHash,
          dependencies: ChatControllerFamily._dependencies,
          allTransitiveDependencies:
              ChatControllerFamily._allTransitiveDependencies,
          itemId: itemId,
          otherUserId: otherUserId,
        );

  ChatControllerProvider._internal(
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
  FutureOr<List<Message>> runNotifierBuild(
    covariant ChatController notifier,
  ) {
    return notifier.build(
      itemId,
      otherUserId,
    );
  }

  @override
  Override overrideWith(ChatController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatControllerProvider._internal(
        () => create()
          ..itemId = itemId
          ..otherUserId = otherUserId,
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
  AutoDisposeAsyncNotifierProviderElement<ChatController, List<Message>>
      createElement() {
    return _ChatControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider &&
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

mixin ChatControllerRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `itemId` of this provider.
  String get itemId;

  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _ChatControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatController,
        List<Message>> with ChatControllerRef {
  _ChatControllerProviderElement(super.provider);

  @override
  String get itemId => (origin as ChatControllerProvider).itemId;
  @override
  String get otherUserId => (origin as ChatControllerProvider).otherUserId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
