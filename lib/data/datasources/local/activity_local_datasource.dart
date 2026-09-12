import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ActivityLocalDataSource {
  static const _searchesKey = 'user_search_history';
  static const _clicksKey = 'user_click_history';
  static const int _maxItems = 30;

  Future<void> addSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_searchesKey) ?? [];
    list.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }
    await prefs.setStringList(_searchesKey, list);
  }

  Future<List<String>> getSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchesKey) ?? [];
  }

  /// Salva id do filme clicado + genre_ids (para afinidade)
  Future<void> addClick({
    required int movieId,
    required List<int> genreIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clicksKey);
    List<Map<String, dynamic>> list = [];

    if (raw != null && raw.isNotEmpty) {
      list = (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    list.removeWhere((e) => e['movieId'] == movieId);
    list.insert(0, {
      'movieId': movieId,
      'genreIds': genreIds,
      'at': DateTime.now().toIso8601String(),
    });

    if (list.length > _maxItems) {
      list = list.sublist(0, _maxItems);
    }

    await prefs.setString(_clicksKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getClicks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clicksKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
