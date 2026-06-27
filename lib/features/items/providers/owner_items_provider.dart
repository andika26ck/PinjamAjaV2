import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_exception.dart';
import '../../../data/models/item.dart';
import '../../auth/providers/auth_provider.dart';
import 'item_detail_provider.dart';

part 'owner_items_provider.g.dart';

/// Tab pada Owner Dashboard, sekaligus filter berdasarkan status barang.
enum OwnerItemTab {
  aktif,
  disewakan,
  nonaktif;

  String get label => switch (this) {
        OwnerItemTab.aktif => 'Aktif',
        OwnerItemTab.disewakan => 'Disewakan',
        OwnerItemTab.nonaktif => 'Nonaktif',
      };

  bool matches(Item item) => switch (this) {
        OwnerItemTab.aktif => item.status == AppConstants.itemStatusAvailable,
        OwnerItemTab.disewakan =>
          item.status == AppConstants.itemStatusRented,
        OwnerItemTab.nonaktif =>
          item.status == AppConstants.itemStatusInactive,
      };
}

@riverpod
Future<List<Item>> ownerItems(OwnerItemsRef ref) async {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) {
    throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
  }
  return ref.watch(itemRepositoryProvider).fetchOwnerItems(userId);
}