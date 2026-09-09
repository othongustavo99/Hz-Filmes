import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies();
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> getUpcomingMovies({int page = 1});
  Future<List<MovieModel>> getNowPlaying({int page = 1});
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getSimilarMovies(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  MovieRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<MovieModel>> getSimilarMovies(int movieId) async {
    final response = await dioClient.dio.get(
      '${ApiConstants.movieDetails}/$movieId/similar',
    );
    return _parseMovieList(response);
  }

  @override
  Future<List<MovieModel>> getTrendingMovies() async {
    final response = await dioClient.dio.get(ApiConstants.trendingMovies);
    return _parseMovieList(response);
  }

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.popularMovies,
      queryParameters: {'page': page},
    );
    return _parseMovieList(response);
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.topRatedMovies,
      queryParameters: {'page': page},
    );
    return _parseMovieList(response);
  }

  @override
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.upcomingMovies,
      queryParameters: {'page': page},
    );
    return _parseMovieList(response);
  }

  @override
  Future<List<MovieModel>> getNowPlaying({int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.nowPlaying,
      queryParameters: {'page': page},
    );
    return _parseMovieList(response);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final response = await dioClient.dio.get(
      ApiConstants.searchMovie,
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': false,
      },
    );
    return _parseMovieList(response);
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await dioClient.dio.get(
      '${ApiConstants.movieDetails}/$movieId',
      queryParameters: {
        'append_to_response': 'credits',
      },
    );
    return MovieModel.fromJson(response.data);
  }

  List<MovieModel> _parseMovieList(Response response) {
    final results = response.data['results'] as List<dynamic>;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }
}
