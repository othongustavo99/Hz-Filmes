import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/domain/repositories/services/recommendation_service.dart';

import '../../../data/models/movie_model.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MovieRepository movieRepository;
  final RecommendationService recommendationService;

  HomeBloc(this.movieRepository, this.recommendationService)
    : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        movieRepository.getTrendingMovies(),
        movieRepository.getPopularMovies(),
        movieRepository.getTopRatedMovies(),
        movieRepository.getUpcomingMovies(),
        movieRepository.getNowPlaying(),
        recommendationService.getRecommendations(),
      ]);

      emit(
        HomeLoaded(
          trending: results[0] as List<MovieModel>,
          popular: results[1] as List<MovieModel>,
          topRated: results[2] as List<MovieModel>,
          upcoming: results[3] as List<MovieModel>,
          nowPlaying: results[4] as List<MovieModel>,
          recommended: results[5] as List<MovieModel>,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
