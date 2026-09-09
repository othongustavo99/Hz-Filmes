import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote/movie_remote_datasource.dart';
import '../models/movie_model.dart';

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

  @override
  Future<List<MovieModel>> getSimilarMovies(int movieId) {
    return remoteDataSource.getSimilarMovies(movieId);
  }
}
