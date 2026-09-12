import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/models/movie_model.dart';
import 'package:hz_filmes/domain/repositories/movie_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class RecommendationService {
  final MovieRepository movieRepository;
  final ActivityLocalDataSource activityDataSource;

  RecommendationService({
    required this.movieRepository,
    required this.activityDataSource,
  });

  /// Monta recomendações com base em:
  /// 1) favoritos
  /// 2) últimos cliques
  /// 3) últimas buscas
  Future<List<MovieModel>> getRecommendations() async {
    final seedIds = <int>{};
    final searchQueries = <String>[];

    // 1. Favoritos
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJson = prefs.getString('favorite_movies');
      if (favJson != null && favJson.isNotEmpty) {
        final list = jsonDecode(favJson) as List<dynamic>;
        for (final item in list) {
          final id = (item as Map)['id'];
          if (id is int) seedIds.add(id);
        }
      }
    } catch (_) {}

    // 2. Cliques
    final clicks = await activityDataSource.getClicks();
    for (final c in clicks.take(10)) {
      final id = c['movieId'];
      if (id is int) seedIds.add(id);
    }

    // 3. Buscas
    searchQueries.addAll(await activityDataSource.getSearches());

    final recommended = <MovieModel>[];
    final seen = <int>{};

    // Similar aos filmes seed (favoritos + cliques)
    for (final id in seedIds.take(5)) {
      try {
        final similar = await movieRepository.getSimilarMovies(id);
        for (final m in similar) {
          if (seen.add(m.id) && !seedIds.contains(m.id)) {
            recommended.add(m);
          }
        }
      } catch (_) {}
      if (recommended.length >= 20) break;
    }

    // Resultados das últimas buscas
    for (final query in searchQueries.take(3)) {
      try {
        final results = await movieRepository.searchMovies(query);
        for (final m in results.take(5)) {
          if (seen.add(m.id) && !seedIds.contains(m.id)) {
            recommended.add(m);
          }
        }
      } catch (_) {}
      if (recommended.length >= 25) break;
    }

    return recommended.take(20).toList();
  }
}
