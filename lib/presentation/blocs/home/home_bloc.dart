import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/domain/repositories/services/recommendation_service.dart';
import 'package:hz_filmes/core/constants/media_category.dart';

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
      if (event.category == MediaCategory.novelas) {
        // Carregamento especial para Novelas
        final results = await Future.wait([
          movieRepository.getTrending(event.category),
          movieRepository.getPopular(event.category),
          movieRepository.getTopRated(event.category),
          movieRepository.getBrazilianNovelas(),
          movieRepository.getNovelas2000s(),
          movieRepository.getNovelas90s(),
          recommendationService.getRecommendations(event.category),
        ]);

        emit(
          HomeLoaded(
            category: event.category,
            trending: results[0] as List<MovieModel>,
            popular: results[1] as List<MovieModel>,
            topRated: results[2] as List<MovieModel>,
            upcoming: const [], // não usamos mais
            nowPlaying: const [], // não usamos mais
            brazilianNovelas: results[3] as List<MovieModel>,
            novelas2000s: results[4] as List<MovieModel>,
            novelas90s: results[5] as List<MovieModel>,
            recommended: results[6] as List<MovieModel>,
          ),
        );
      } else {
        // Comportamento normal das outras categorias
        final results = await Future.wait([
          movieRepository.getTrending(event.category),
          movieRepository.getPopular(event.category),
          movieRepository.getTopRated(event.category),
          movieRepository.getUpcoming(event.category),
          movieRepository.getNowPlaying(event.category),
          recommendationService.getRecommendations(event.category),
        ]);

        emit(
          HomeLoaded(
            category: event.category,
            trending: results[0] as List<MovieModel>,
            popular: results[1] as List<MovieModel>,
            topRated: results[2] as List<MovieModel>,
            upcoming: results[3] as List<MovieModel>,
            nowPlaying: results[4] as List<MovieModel>,
            recommended: results[5] as List<MovieModel>,
          ),
        );
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
