part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchMovies extends SearchEvent {
  final String query;
  final MediaCategory category;

  const SearchMovies(
    this.query, {
    required this.category,
  });

  @override
  List<Object> get props => [query, category];
}

class LoadMoreSearchResults extends SearchEvent {}

class ClearSearch extends SearchEvent {}
