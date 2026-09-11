import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/data/models/watch_provider_model.dart';

import '../../../data/models/movie_model.dart';
import '../../../data/models/video_model.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieRepository movieRepository;

  MovieDetailBloc(this.movieRepository) : super(MovieDetailInitial()) {
    on<LoadMovieDetail>(_onLoadMovieDetail);
  }

  Future<void> _onLoadMovieDetail(
    LoadMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(MovieDetailLoading());

    try {
      final results = await Future.wait([
        movieRepository.getMovieDetails(event.movieId),
        movieRepository.getSimilarMovies(event.movieId),
        movieRepository.getMovieVideos(event.movieId),
        movieRepository.getWatchProviders(event.movieId),
      ]);

      final movie = results[0] as MovieModel;
      final similar = results[1] as List<MovieModel>;
      final trailers = results[2] as List<VideoModel>;
      final providers = results[3] as WatchProvidersResult;

      emit(
        MovieDetailLoaded(
          movie: movie,
          similarMovies: similar,
          trailers: trailers,
          watchProviders: providers,
        ),
      );
    } catch (e) {
      emit(MovieDetailError(e.toString()));
    }
  }
}
