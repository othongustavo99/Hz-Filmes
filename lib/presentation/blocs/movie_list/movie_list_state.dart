part of 'movie_list_bloc.dart';

abstract class MovieListState extends Equatable {
  const MovieListState();

  @override
  List<Object?> get props => [];
}

class MovieListInitial extends MovieListState {}

class MovieListLoading extends MovieListState {}

class MovieListLoaded extends MovieListState {
  final List<MovieModel> movies;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const MovieListLoaded({
    required this.movies,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  MovieListLoaded copyWith({
    List<MovieModel>? movies,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return MovieListLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    movies,
    currentPage,
    hasReachedMax,
    isLoadingMore,
  ];
}

class MovieListError extends MovieListState {
  final String message;

  const MovieListError(this.message);

  @override
  List<Object?> get props => [message];
}
