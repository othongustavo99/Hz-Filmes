part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MovieModel> trending;
  final List<MovieModel> popular;
  final List<MovieModel> topRated;
  final List<MovieModel> upcoming;
  final List<MovieModel> nowPlaying;
  final List<MovieModel> recommended; // novo

  const HomeLoaded({
    required this.trending,
    required this.popular,
    required this.topRated,
    required this.upcoming,
    required this.nowPlaying,
    this.recommended = const [],
  });

  @override
  List<Object?> get props => [
    trending,
    popular,
    topRated,
    upcoming,
    nowPlaying,
    recommended,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
