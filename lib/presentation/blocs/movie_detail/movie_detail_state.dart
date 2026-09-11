part of 'movie_detail_bloc.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieModel movie;
  final List<MovieModel> similarMovies;
  final List<VideoModel> trailers;
  final WatchProvidersResult watchProviders;

  const MovieDetailLoaded({
    required this.movie,
    this.similarMovies = const [],
    this.trailers = const [],
    this.watchProviders = const WatchProvidersResult(),
  });

  @override
  List<Object?> get props => [movie, similarMovies, trailers, watchProviders];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);

  @override
  List<Object?> get props => [message];
}