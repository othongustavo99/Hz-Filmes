import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:hz_filmes/core/constants/api_constants.dart';
import 'package:hz_filmes/core/constants/media_category.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/models/movie_model.dart';
import 'package:hz_filmes/domain/repositories/movie_repository.dart';

class RecommendationService {
  final MovieRepository movieRepository;
  final ActivityLocalDataSource activityDataSource;

  RecommendationService({
    required this.movieRepository,
    required this.activityDataSource,
  });

  /// Retorna recomendações de acordo com a categoria atual.
  ///
  /// Filmes  -> somente filmes
  /// Séries  -> somente séries
  /// Animes  -> somente animes
  /// Novelas -> somente novelas
  Future<List<MovieModel>> getRecommendations(
    MediaCategory category,
  ) async {
    final seedIds = <int>{};
    final searchQueries = <String>[];

    // ==========================================================
    // 1. FAVORITOS
    // ==========================================================
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJson = prefs.getString('favorite_movies');

      if (favJson != null && favJson.isNotEmpty) {
        final list = jsonDecode(favJson) as List<dynamic>;

        for (final item in list) {
          final map = item as Map;
          final id = map['id'];

          if (id is int) {
            seedIds.add(id);
          }
        }
      }
    } catch (_) {}

    // ==========================================================
    // 2. CLIQUES
    // ==========================================================
    final clicks = await activityDataSource.getClicks();

    for (final click in clicks.take(15)) {
      final id = click['movieId'];

      if (id is int) {
        seedIds.add(id);
      }
    }

    // ==========================================================
    // 3. BUSCAS
    // ==========================================================
    searchQueries.addAll(
      await activityDataSource.getSearches(),
    );

    final recommended = <MovieModel>[];
    final seen = <int>{};

    // ==========================================================
    // 4. CONTEÚDOS SEMELHANTES
    // ==========================================================
    for (final id in seedIds.take(8)) {
      try {
        // Primeiro descobrimos se o conteúdo realmente
        // pertence à categoria atual.
        final seed = await movieRepository.getDetails(
          id,
          isTv: category.isTv,
        );

        if (!_matchesCategory(seed, category)) {
          continue;
        }

        // Agora buscamos similares usando o tipo correto.
        final similar = await movieRepository.getSimilar(
          id,
          isTv: category.isTv,
        );

        for (final movie in similar) {
          // Garante que o resultado também pertença
          // à categoria atual.
          if (!_matchesCategory(movie, category)) {
            continue;
          }

          if (seen.add(movie.id) &&
              !seedIds.contains(movie.id)) {
            recommended.add(movie);
          }
        }
      } catch (_) {}

      if (recommended.length >= 20) {
        break;
      }
    }

    // ==========================================================
    // 5. RECOMENDAÇÕES BASEADAS NAS BUSCAS
    // ==========================================================
    for (final query in searchQueries.take(5)) {
      try {
        final results = await movieRepository.search(
          query,
          category,
          page: 1,
        );

        for (final movie in results) {
          if (!_matchesCategory(movie, category)) {
            continue;
          }

          if (seen.add(movie.id) &&
              !seedIds.contains(movie.id)) {
            recommended.add(movie);
          }
        }
      } catch (_) {}

      if (recommended.length >= 20) {
        break;
      }
    }

    // ==========================================================
    // 6. FALLBACK
    // ==========================================================
    //
    // Se o usuário ainda não tiver histórico suficiente,
    // usamos conteúdos populares DA CATEGORIA ATUAL.
    //
    if (recommended.length < 10) {
      try {
        final popular = await movieRepository.getPopular(
          category,
          page: 1,
        );

        for (final movie in popular) {
          if (!_matchesCategory(movie, category)) {
            continue;
          }

          if (seen.add(movie.id) &&
              !seedIds.contains(movie.id)) {
            recommended.add(movie);
          }
        }
      } catch (_) {}
    }

    return recommended.take(20).toList();
  }

  // ============================================================
  // VALIDA CATEGORIA
  // ============================================================

  bool _matchesCategory(
    MovieModel movie,
    MediaCategory category,
  ) {
    switch (category) {
      // Filmes já vêm do endpoint de filmes.
      case MediaCategory.movies:
        return true;

      // Séries já vêm do endpoint de TV.
      case MediaCategory.series:
        return true;

      // Anime precisa ser:
      // - TV
      // - animação
      // - idioma original japonês
      case MediaCategory.animes:
        final isAnimation = movie.genreIds.contains(
          ApiConstants.genreAnimation,
        );

        final isJapanese =
            movie.originalLanguage == 'ja';

        return isAnimation && isJapanese;

      // Novela precisa ser:
      // - TV
      // - gênero novela
      // - português ou espanhol
      case MediaCategory.novelas:
        final isSoap = movie.genreIds.contains(
          ApiConstants.genreSoap,
        );

        final isPortuguese =
            movie.originalLanguage == 'pt';

        final isSpanish =
            movie.originalLanguage == 'es';

        return isSoap &&
            (isPortuguese || isSpanish);
    }
  }
}