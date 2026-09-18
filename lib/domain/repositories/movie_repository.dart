import '../../data/models/movie_model.dart';
import '../../data/models/video_model.dart';
import '../../data/models/watch_provider_model.dart';
import '../../core/constants/media_category.dart';

abstract class MovieRepository {
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
