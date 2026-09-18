import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/core/constants/media_category.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/datasources/remote/activity_remote_datasource.dart';

import '../../../data/models/movie_model.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository movieRepository;

  SearchBloc(this.movieRepository) : super(SearchInitial()) {
    on<SearchMovies>(_onSearchMovies);
    on<LoadMoreSearchResults>(_onLoadMore);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final movies = await movieRepository.search(
        query,
        event.category,
        page: 1,
      );

      if (movies.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(
          SearchLoaded(
            movies: movies,
            query: query,
            category: event.category,
            currentPage: 1,
            hasReachedMax: movies.length < 20,
          ),
        );
      }

      await ActivityLocalDataSource().addSearch(query);
      ActivityRemoteDataSource().addSearch(query);
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;

    if (currentState is! SearchLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;

      final newMovies = await movieRepository.search(
        currentState.query,
        currentState.category,
        page: nextPage,
      );

      if (newMovies.isEmpty) {
        emit(
          currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            movies: [
              ...currentState.movies,
              ...newMovies,
            ],
            currentPage: nextPage,
            hasReachedMax: newMovies.length < 20,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
        ),
      );
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
