import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../data/models/item.dart';
import '../data/search_filters.dart';
import 'home_provider.dart';
import 'search_history_provider.dart';

part 'search_provider.g.dart';

class SearchUiState {
  final String query;
  final SearchFilters filters;
  final AsyncValue<List<Item>> results;
  final bool hasSearched;

  const SearchUiState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.results = const AsyncValue.data(<Item>[]),
    this.hasSearched = false,
  });

  SearchUiState copyWith({
    String? query,
    SearchFilters? filters,
    AsyncValue<List<Item>>? results,
    bool? hasSearched,
  }) =>
      SearchUiState(
        query: query ?? this.query,
        filters: filters ?? this.filters,
        results: results ?? this.results,
        hasSearched: hasSearched ?? this.hasSearched,
      );
}

@riverpod
class SearchController extends _$SearchController {
  Timer? _debounce;

  @override
  SearchUiState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchUiState();
  }

  /// Dipanggil tiap ketikan; debounce 400ms sebelum query ke Supabase.
  void setQuery(String value) {
    state = state.copyWith(query: value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), run);
  }

  void applyFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    run();
  }

  void resetFilters() {
    state = state.copyWith(filters: const SearchFilters());
    run();
  }

  Future<void> run() async {
    _debounce?.cancel();
    final query = state.query.trim();
    final filters = state.filters;

    if (query.isEmpty && !filters.hasActiveFilter) {
      state = state.copyWith(
        results: const AsyncValue.data(<Item>[]),
        hasSearched: false,
      );
      return;
    }

    state = state.copyWith(
      results: const AsyncValue.loading(),
      hasSearched: true,
    );
    try {
      final items = await ref
          .read(homeRepositoryProvider)
          .searchItems(query: query, filters: filters);
      if (query.isNotEmpty) {
        await ref.read(searchHistoryProvider.notifier).add(query);
      }
      state = state.copyWith(results: AsyncValue.data(items));
    } catch (e, st) {
      state = state.copyWith(results: AsyncValue.error(e.toAppException(), st));
    }
  }
}