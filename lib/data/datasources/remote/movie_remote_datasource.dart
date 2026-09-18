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
  Future<List<MovieModel>> search(
    String query,
    MediaCategory category, {
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
    switch (category) {
      case MediaCategory.movies:
        final response = await dioClient.dio.get(
          ApiConstants.upcomingMovies,
          queryParameters: {'page': page},
        );
        return _parseMovieList(response);
      case MediaCategory.series:
      case MediaCategory.animes:
      case MediaCategory.novelas:
        // Para TV usamos on_the_air como "em breve / no ar"
        final response = await dioClient.dio.get(
          ApiConstants.onTheAir,
          queryParameters: {'page': page},
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
      case MediaCategory.animes:
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
    return _parseMovieList(response);
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
}
