part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchMovies extends SearchEvent {
  final String query;

  const SearchMovies(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends SearchEvent {}