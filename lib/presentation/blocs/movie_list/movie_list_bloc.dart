import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/movie_model.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'movie_list_event.dart';
part 'movie_list_state.dart';

enum MovieListType {
  popular,
  topRated,
  upcoming,
  nowPlaying,
  trending,
}

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final MovieRepository movieRepository;
  final MovieListType type;

  MovieListBloc({
    required this.movieRepository,
    required this.type,
  }) : super(MovieListInitial()) {
    on<LoadMovieList>(_onLoad);
    on<LoadMoreMovies>(_onLoadMore);
  }

  Future<List<MovieModel>> _fetch(int page) {
    switch (type) {
      case MovieListType.popular:
        return movieRepository.getPopularMovies(page: page);
      case MovieListType.topRated:
        return movieRepository.getTopRatedMovies(page: page);
      case MovieListType.upcoming:
        return movieRepository.getUpcomingMovies(page: page);
      case MovieListType.nowPlaying:
        return movieRepository.getNowPlaying(page: page);
      case MovieListType.trending:
        return movieRepository.getTrendingMovies();
    }
  }

  Future<void> _onLoad(
    LoadMovieList event,
    Emitter<MovieListState> emit,
  ) async {
    emit(MovieListLoading());

    try {
      final movies = await _fetch(1);
      emit(
        MovieListLoaded(
          movies: movies,
          currentPage: 1,
          hasReachedMax: type == MovieListType.trending || movies.length < 20,
        ),
      );
    } catch (e) {
      emit(MovieListError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMovies event,
    Emitter<MovieListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MovieListLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;
    if (type == MovieListType.trending)
      return; // trending não tem paginação fácil

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newMovies = await _fetch(nextPage);

      if (newMovies.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
      } else {
        emit(
          currentState.copyWith(
            movies: [...currentState.movies, ...newMovies],
            currentPage: nextPage,
            hasReachedMax: newMovies.length < 20,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
