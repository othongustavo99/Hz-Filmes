import '../../domain/repositories/movie_repository.dart';
import '../../core/constants/media_category.dart';
import '../datasources/remote/movie_remote_datasource.dart';
import '../models/movie_model.dart';
import '../models/video_model.dart';
import '../models/watch_provider_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MovieModel>> getTrending(MediaCategory category) {
    return remoteDataSource.getTrending(category);
  }

  @override
  Future<List<MovieModel>> getPopular(MediaCategory category, {int page = 1}) {
    return remoteDataSource.getPopular(category, page: page);
  }

  @override
  Future<List<MovieModel>> getTopRated(MediaCategory category, {int page = 1}) {
    return remoteDataSource.getTopRated(category, page: page);
  }

  @override
  Future<List<MovieModel>> getUpcoming(MediaCategory category, {int page = 1}) {
    return remoteDataSource.getUpcoming(category, page: page);
  }

  @override
  Future<List<MovieModel>> getNowPlaying(
    MediaCategory category, {
    int page = 1,
  }) {
    return remoteDataSource.getNowPlaying(category, page: page);
  }

  @override
  Future<List<MovieModel>> search(
    String query,
    MediaCategory category, {
    int page = 1,
  }) {
    return remoteDataSource.search(query, category, page: page);
  }

  @override
  Future<MovieModel> getDetails(int id, {required bool isTv}) {
    return remoteDataSource.getDetails(id, isTv: isTv);
  }

  @override
  Future<List<MovieModel>> getSimilar(int id, {required bool isTv}) {
    return remoteDataSource.getSimilar(id, isTv: isTv);
  }

  @override
  Future<List<VideoModel>> getVideos(int id, {required bool isTv}) {
    return remoteDataSource.getVideos(id, isTv: isTv);
  }

  @override
  Future<WatchProvidersResult> getWatchProviders(int id, {required bool isTv}) {
    return remoteDataSource.getWatchProviders(id, isTv: isTv);
  }

  @override
  Future<List<MovieModel>> getByGenre(
    MediaCategory category,
    int genreId, {
    int page = 1,
  }) {
    return remoteDataSource.getByGenre(
      category,
      genreId,
      page: page,
    );
  }
}
