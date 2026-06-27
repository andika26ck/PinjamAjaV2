import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_history_provider.g.dart';

/// Menyimpan riwayat pencarian di SharedPreferences (maks 8 item).
@Riverpod(keepAlive: true)
class SearchHistory extends _$SearchHistory {
  static const _key = 'search_history';
  static const _max = 8;

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = [...(state.valueOrNull ?? <String>[])]
      ..removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    final trimmed = list.take(_max).toList();
    await prefs.setStringList(_key, trimmed);
    state = AsyncData(trimmed);
  }

  Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = [...(state.valueOrNull ?? <String>[])]..remove(query);
    await prefs.setStringList(_key, list);
    state = AsyncData(list);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncData(<String>[]);
  }
}