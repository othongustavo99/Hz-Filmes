import '../../data/models/movie_model.dart';
import '../../data/models/video_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> getTrendingMovies();
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> getUpcomingMovies({int page = 1});
  Future<List<MovieModel>> getNowPlaying({int page = 1});
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getSimilarMovies(int movieId);
  Future<List<VideoModel>> getMovieVideos(int movieId);
}
