// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchHistoryHash() => r'398fc94074521e0c3c9f2c84aa6b781c58afd966';

/// Menyimpan riwayat pencarian di SharedPreferences (maks 8 item).
///
/// Copied from [SearchHistory].
@ProviderFor(SearchHistory)
final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistory, List<String>>.internal(
  SearchHistory.new,
  name: r'searchHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchHistory = AsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
