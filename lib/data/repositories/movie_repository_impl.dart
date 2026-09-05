import 'package:hz_filmes/data/datasources/remote/movie_remote_datasource.dart';
import 'package:hz_filmes/data/models/movie_model.dart';

import '../../domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MovieModel>> getTrendingMovies() {
    return remoteDataSource.getTrendingMovies();
  }

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) {
    return remoteDataSource.getPopularMovies(page: page);
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) {
    return remoteDataSource.getTopRatedMovies(page: page);
  }

  @override
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) {
    return remoteDataSource.getUpcomingMovies(page: page);
  }

  @override
  Future<List<MovieModel>> getNowPlaying({int page = 1}) {
    return remoteDataSource.getNowPlaying(page: page);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) {
    return remoteDataSource.searchMovies(query, page: page);
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) {
    return remoteDataSource.getMovieDetails(movieId);
  }
}