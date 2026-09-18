part of 'movie_detail_bloc.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadMovieDetail extends MovieDetailEvent {
  final int movieId;
  final bool isTv;

  const LoadMovieDetail(this.movieId, {this.isTv = false});

  @override
  List<Object> get props => [movieId];
}
