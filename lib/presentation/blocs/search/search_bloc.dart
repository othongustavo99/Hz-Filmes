import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository movieRepository;

  SearchBloc(this.movieRepository) : super(SearchInitial()) {
    on<SearchMovies>(_onSearchMovies);
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
      final movies = await movieRepository.searchMovies(query);

      if (movies.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchLoaded(movies: movies, query: query));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}