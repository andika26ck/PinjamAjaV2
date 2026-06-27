import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_exception.dart';
import '../../../data/models/item.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../data/item_repository.dart';
import 'item_detail_provider.dart';
import 'owner_items_provider.dart';
import 'owner_stats_provider.dart';

part 'add_edit_item_provider.g.dart';

/// Controller form Add/Edit. State `AsyncValue<void>` untuk loading & error.
@riverpod
class AddEditItemController extends _$AddEditItemController {
  @override
  FutureOr<void> build() {}

  String _ownerId() {
    final id = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
    }
    return id;
  }

  /// Unggah foto baru, kembalikan daftar URL publik (urut sesuai input).
  Future<List<String>> uploadImages(List<ItemImageUpload> images) async {
    if (images.isEmpty) return [];
    return ref
        .read(itemRepositoryProvider)
        .uploadImages(ownerId: _ownerId(), images: images);
  }

  /// Simpan barang. `itemId == null` -> create, selain itu -> update.
  Future<Item?> save({
    String? itemId,
    required String title,
    required String categoryId,
    required ItemCondition condition,
    required String description,
    required int pricePerDay,
    required int depositAmount,
    required String location,
    double? latitude,
    double? longitude,
    required List<String> imageUrls,
    required List<DateTime> blockedDates,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(itemRepositoryProvider);
      final base = <String, dynamic>{
        'title': title.trim(),
        'category_id': categoryId,
        'condition': condition.value,
        'description': description.trim(),
        'price_per_day': pricePerDay,
        'deposit_amount': depositAmount,
        'location': location.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'image_urls': imageUrls,
        'blocked_dates': blockedDates.map(_fmtDate).toList(),
      };

      final Item result;
      if (itemId == null) {
        result = await repo.createItem({
          ...base,
          'owner_id': _ownerId(),
          'status': AppConstants.itemStatusAvailable,
        });
      } else {
        result = await repo.updateItem(id: itemId, payload: base);
      }

      _invalidateLists(itemId);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return null;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    state = const AsyncLoading();
    try {
      await ref.read(itemRepositoryProvider).deleteItem(itemId);
      _invalidateLists(itemId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  // Segarkan daftar terkait agar UI ikut ter-update.
  void _invalidateLists(String? itemId) {
    ref.invalidate(ownerItemsProvider);
    ref.invalidate(ownerItemStatsProvider);
    ref.invalidate(nearbyItemsProvider);
    ref.invalidate(popularItemsProvider);
    if (itemId != null) ref.invalidate(itemDetailProvider(itemId));
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}