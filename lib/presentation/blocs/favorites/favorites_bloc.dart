import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/movie_model.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  static const String _favoritesKey = 'favorite_movies';

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson == null || favoritesJson.isEmpty) {
        emit(const FavoritesLoaded([]));
        return;
      }

      final List<dynamic> decoded = jsonDecode(favoritesJson);
      final favorites = decoded
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();

      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    final currentFavorites = List<MovieModel>.from(currentState.favorites);
    final movie = event.movie;

    final alreadyFavorite = currentFavorites.any((m) => m.id == movie.id);

    if (alreadyFavorite) {
      currentFavorites.removeWhere((m) => m.id == movie.id);
    } else {
      currentFavorites.add(movie);
    }

    // Salva no SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        currentFavorites
            .map(
              (m) => {
                'id': m.id,
                'title': m.title,
                'overview': m.overview,
                'poster_path': m.posterPath,
                'backdrop_path': m.backdropPath,
                'vote_average': m.voteAverage,
                'vote_count': m.voteCount,
                'release_date': m.releaseDate,
                'genre_ids': m.genreIds,
                'adult': m.adult,
                'original_language': m.originalLanguage,
                'original_title': m.originalTitle,
                'popularity': m.popularity,
              },
            )
            .toList(),
      );

      await prefs.setString(_favoritesKey, encoded);
      emit(FavoritesLoaded(currentFavorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
