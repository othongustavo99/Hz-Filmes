import 'package:dio/dio.dart';

import '../../../core/constants/media_category.dart';
import '../../models/watch_provider_model.dart';
import '../../models/video_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrending(MediaCategory category);
  Future<List<MovieModel>> getPopular(MediaCategory category, {int page = 1});
  Future<List<MovieModel>> getTopRated(MediaCategory category, {int page = 1});
  Future<List<MovieModel>> getUpcoming(MediaCategory category, {int page = 1});
  Future<List<MovieModel>> getNowPlaying(
    MediaCategory category, {
    int page = 1,
  });
  Future<List<MovieModel>> getBrazilianNovelas({int page = 1});
  Future<List<MovieModel>> getNovelas2000s({int page = 1});
  Future<List<MovieModel>> getNovelas90s({int page = 1});
  Future<List<MovieModel>> search(
    String query,
    MediaCategory category, {
    int page = 1,
  });
  Future<List<MovieModel>> getByGenre(
    MediaCategory category,
    int genreId, {
    int page = 1,
  });
  Future<MovieModel> getDetails(int id, {required bool isTv});
  Future<List<MovieModel>> getSimilar(int id, {required bool isTv});
  Future<List<VideoModel>> getVideos(int id, {required bool isTv});
  Future<WatchProvidersResult> getWatchProviders(int id, {required bool isTv});
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  MovieRemoteDataSourceImpl(this.dioClient);

  List<MovieModel> _parseMovieList(Response response) {
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  // ---------- TRENDING ----------
  @override
  Future<List<MovieModel>> getTrending(MediaCategory category) async {
    switch (category) {
      case MediaCategory.movies:
        final response = await dioClient.dio.get(ApiConstants.trendingMovies);
        return _parseMovieList(response);
      case MediaCategory.series:
        final response = await dioClient.dio.get(ApiConstants.trendingTv);
        return _parseMovieList(response);
      case MediaCategory.animes:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': ApiConstants.genreAnimation,
            'with_original_language': 'ja',
            'sort_by': 'popularity.desc',
          },
        );
        return _parseMovieList(response);
      case MediaCategory.novelas:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres':
                '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
            'with_original_language': 'pt|es',
            'sort_by': 'popularity.desc',
          },
        );
        return _parseMovieList(response);
    }
  }

  // ---------- POPULAR ----------
  @override
  Future<List<MovieModel>> getPopular(
    MediaCategory category, {
    int page = 1,
  }) async {
    switch (category) {
      case MediaCategory.movies:
        final response = await dioClient.dio.get(
          ApiConstants.popularMovies,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);
      case MediaCategory.series:
        final response = await dioClient.dio.get(
          ApiConstants.popularTv,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);
      case MediaCategory.animes:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': ApiConstants.genreAnimation,
            'with_original_language': 'ja',
            'sort_by': 'popularity.desc',
            'page': page,
          },
        );
        return _parseMovieList(response);
      case MediaCategory.novelas:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres':
                '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
            'with_original_language': 'pt|es',
            'sort_by': 'popularity.desc',
            'page': page,
          },
        );
        return _parseMovieList(response);
    }
  }

  // ---------- TOP RATED ----------
  @override
  Future<List<MovieModel>> getTopRated(
    MediaCategory category, {
    int page = 1,
  }) async {
    switch (category) {
      case MediaCategory.movies:
        final response = await dioClient.dio.get(
          ApiConstants.topRatedMovies,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);
      case MediaCategory.series:
        final response = await dioClient.dio.get(
          ApiConstants.topRatedTv,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);
      case MediaCategory.animes:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': ApiConstants.genreAnimation,
            'with_original_language': 'ja',
            'sort_by': 'vote_average.desc',
            'vote_count.gte': 100,
            'page': page,
          },
        );
        return _parseMovieList(response);
      case MediaCategory.novelas:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres':
                '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
            'with_original_language': 'pt|es',
            'sort_by': 'vote_average.desc',
            'vote_count.gte': 50,
            'page': page,
          },
        );
        return _parseMovieList(response);
    }
  }

  // ---------- UPCOMING / EM BREVE ----------
  @override
  Future<List<MovieModel>> getUpcoming(
    MediaCategory category, {
    int page = 1,
  }) async {
    final now = DateTime.now();

    // Considera como "Em breve" conteúdos que serão lançados
    // a partir de hoje, dentro dos próximos 6 meses.
    final from = now.toIso8601String().substring(0, 10);

    final to = DateTime(
      now.year,
      now.month + 6,
      now.day,
    ).toIso8601String().substring(0, 10);

    switch (category) {
      // ==================== FILMES ====================
      case MediaCategory.movies:
        final response = await dioClient.dio.get(
          ApiConstants.upcomingMovies,
          queryParameters: {
            'page': page,
            'region': 'BR',
          },
        );

        return _parseMovieList(response);

      // ==================== SÉRIES ====================
      case MediaCategory.series:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'first_air_date.gte': from,
            'first_air_date.lte': to,
            'sort_by': 'first_air_date.asc',
            'page': page,
            'include_adult': false,
          },
        );

        return _parseMovieList(response);

      // ==================== ANIMES ====================
      case MediaCategory.animes:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': ApiConstants.genreAnimation,
            'with_original_language': 'ja',
            'first_air_date.gte': from,
            'first_air_date.lte': to,
            'sort_by': 'first_air_date.asc',
            'page': page,
            'include_adult': false,
          },
        );

        return _parseMovieList(response);

      // ==================== NOVELAS ====================
      case MediaCategory.novelas:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres':
                '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
            'with_original_language': 'pt|es',
            'first_air_date.gte': from,
            'first_air_date.lte': to,
            'sort_by': 'first_air_date.asc',
            'page': page,
            'include_adult': false,
          },
        );

        return _parseMovieList(response);
    }
  }

  // ---------- NOW PLAYING / EM CARTAZ ----------
  @override
  Future<List<MovieModel>> getNowPlaying(
    MediaCategory category, {
    int page = 1,
  }) async {
    switch (category) {
      case MediaCategory.movies:
        final response = await dioClient.dio.get(
          ApiConstants.nowPlaying,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);

      case MediaCategory.series:
        final response = await dioClient.dio.get(
          ApiConstants.airingToday,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);

      case MediaCategory.animes:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': ApiConstants.genreAnimation,
            'with_original_language': 'ja',
            'sort_by': 'popularity.desc',
            'vote_count.gte': 30,
            'page': page,
            'include_adult': false,
          },
        );
        return _parseMovieList(response);

      case MediaCategory.novelas:
        final response = await dioClient.dio.get(
          ApiConstants.airingToday,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);
    }
  }

  // ---------- SEARCH ----------
  @override
  Future<List<MovieModel>> search(
    String query,
    MediaCategory category, {
    int page = 1,
  }) async {
    final endpoint = category.isTv
        ? ApiConstants.searchTv
        : ApiConstants.searchMovie;

    final response = await dioClient.dio.get(
      endpoint,
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': false,
      },
    );

    final results = _parseMovieList(response);

    // Filmes e séries normais não precisam
    // de filtros adicionais.
    if (category == MediaCategory.movies || category == MediaCategory.series) {
      return results;
    }

    // ==================== ANIMES ====================
    if (category == MediaCategory.animes) {
      return results.where((movie) {
        final isAnimation = movie.genreIds.contains(
          ApiConstants.genreAnimation,
        );

        final isJapanese = movie.originalLanguage == 'ja';

        return isAnimation && isJapanese;
      }).toList();
    }

    // ==================== NOVELAS ====================
    if (category == MediaCategory.novelas) {
      return results.where((movie) {
        final isPortuguese = movie.originalLanguage == 'pt';

        final isSpanish = movie.originalLanguage == 'es';

        final isSoap = movie.genreIds.contains(
          ApiConstants.genreSoap,
        );

        return (isPortuguese || isSpanish) && isSoap;
      }).toList();
    }

    return results;
  }

  // ---------- FILTRO POR GÊNERO ----------
  @override
  Future<List<MovieModel>> getByGenre(
    MediaCategory category,
    int genreId, {
    int page = 1,
  }) async {
    switch (category) {
      // ==================== FILMES ====================
      case MediaCategory.movies:
        final response = await dioClient.dio.get(
          ApiConstants.discoverMovie,
          queryParameters: {
            'with_genres': genreId,
            'sort_by': 'popularity.desc',
            'page': page,
            'include_adult': false,
          },
        );

        return _parseMovieList(response);

      // ==================== SÉRIES ====================
      case MediaCategory.series:
        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': genreId,
            'sort_by': 'popularity.desc',
            'page': page,
            'include_adult': false,
          },
        );

        return _parseMovieList(response);

      // ==================== ANIMES ====================
      case MediaCategory.animes:
        final Map<String, dynamic> params = {
          'with_genres': genreId == ApiConstants.genreAnimation
              ? '${ApiConstants.genreAnimation}'
              : '${ApiConstants.genreAnimation},$genreId',
          'with_original_language': 'ja',
          'sort_by': 'popularity.desc',
          'page': page,
          'include_adult': false,
        };

        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: params,
        );

        return _parseMovieList(response);

      // ==================== NOVELAS ====================
      case MediaCategory.novelas:
        final String genres;

        if (genreId == ApiConstants.genreSoap) {
          // "Todas"
          genres = '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}';
        } else {
          genres = '$genreId';
        }

        final response = await dioClient.dio.get(
          ApiConstants.discoverTv,
          queryParameters: {
            'with_genres': genres,
            'with_original_language': 'pt|es',
            'sort_by': 'popularity.desc',
            'page': page,
            'include_adult': false,
          },
        );

        return _parseMovieList(response);
    }
  }

  // ---------- DETAILS ----------
  @override
  Future<MovieModel> getDetails(int id, {required bool isTv}) async {
    final endpoint = isTv
        ? '${ApiConstants.tvDetails}/$id'
        : '${ApiConstants.movieDetails}/$id';

    final response = await dioClient.dio.get(
      endpoint,
      queryParameters: {
        'append_to_response': 'credits',
      },
    );
    return MovieModel.fromJson(response.data);
  }

  // ---------- SIMILAR ----------
  @override
  Future<List<MovieModel>> getSimilar(int id, {required bool isTv}) async {
    final endpoint = isTv
        ? '${ApiConstants.tvDetails}/$id/similar'
        : '${ApiConstants.movieDetails}/$id/similar';

    final response = await dioClient.dio.get(endpoint);
    return _parseMovieList(response);
  }

  // ---------- VIDEOS ----------
  @override
  Future<List<VideoModel>> getVideos(int id, {required bool isTv}) async {
    final endpoint = isTv
        ? '${ApiConstants.tvDetails}/$id/videos'
        : '${ApiConstants.movieDetails}/$id/videos';

    final response = await dioClient.dio.get(endpoint);
    final results = response.data['results'] as List<dynamic>? ?? [];

    return results
        .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
        .where((video) => video.isYoutube && video.isTrailer)
        .toList();
  }

  // ---------- WATCH PROVIDERS ----------
  @override
  Future<WatchProvidersResult> getWatchProviders(
    int id, {
    required bool isTv,
  }) async {
    final endpoint = isTv
        ? '${ApiConstants.tvDetails}/$id/watch/providers'
        : '${ApiConstants.movieDetails}/$id/watch/providers';

    final response = await dioClient.dio.get(endpoint);
    final results = response.data['results'] as Map<String, dynamic>? ?? {};

    final br = results['BR'] as Map<String, dynamic>?;
    final us = results['US'] as Map<String, dynamic>?;

    final providers = WatchProvidersResult.fromJson(br);
    if (providers.isEmpty && us != null) {
      return WatchProvidersResult.fromJson(us);
    }
    return providers;
  }

  // ---------- NOVELAS BRASILEIRAS ----------
  Future<List<MovieModel>> getBrazilianNovelas({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.discoverTv,
      queryParameters: {
        'with_genres': '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
        'with_original_language': 'pt',
        'with_origin_country': 'BR',
        'sort_by': 'popularity.desc',
        'vote_count.gte': 30,
        'page': page,
        'include_adult': false,
      },
    );
    return _parseMovieList(response);
  }

  // ---------- NOVELAS DOS ANOS 2000 ----------
  Future<List<MovieModel>> getNovelas2000s({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.discoverTv,
      queryParameters: {
        'with_genres': '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
        'with_original_language': 'pt|es',
        'first_air_date.gte': '2000-01-01',
        'first_air_date.lte': '2009-12-31',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': 20,
        'page': page,
        'include_adult': false,
      },
    );
    return _parseMovieList(response);
  }

  // ---------- NOVELAS DOS ANOS 90 ----------
  Future<List<MovieModel>> getNovelas90s({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.discoverTv,
      queryParameters: {
        'with_genres': '${ApiConstants.genreSoap}|${ApiConstants.genreDrama}',
        'with_original_language': 'pt|es',
        'first_air_date.gte': '1990-01-01',
        'first_air_date.lte': '1999-12-31',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': 15,
        'page': page,
        'include_adult': false,
      },
    );
    return _parseMovieList(response);
  }
}
