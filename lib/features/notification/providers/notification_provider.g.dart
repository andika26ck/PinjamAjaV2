// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRepositoryHash() =>
    r'c90b1e61fec4ed51373a8d294c9c478f6cfe625c';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    Provider<NotificationRepository>.internal(
  notificationRepository,
  name: r'notificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationRepositoryRef = ProviderRef<NotificationRepository>;
String _$notificationListHash() => r'de2f2f2297c909ef7b187888b9509b00445cdd89';

/// Daftar notifikasi user (terbaru di atas) + auto-refresh realtime.
///
/// Copied from [NotificationList].
@ProviderFor(NotificationList)
final notificationListProvider =
    AsyncNotifierProvider<NotificationList, List<AppNotification>>.internal(
  NotificationList.new,
  name: r'notificationListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationList = AsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
