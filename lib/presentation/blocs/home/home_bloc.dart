import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MovieRepository movieRepository;

  HomeBloc(this.movieRepository) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // Fazemos várias requisições em paralelo (muito mais rápido)
      final results = await Future.wait([
        movieRepository.getTrendingMovies(),
        movieRepository.getPopularMovies(),
        movieRepository.getTopRatedMovies(),
        movieRepository.getUpcomingMovies(),
        movieRepository.getNowPlaying(),
      ]);

      emit(HomeLoaded(
        trending: results[0],
        popular: results[1],
        topRated: results[2],
        upcoming: results[3],
        nowPlaying: results[4],
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}