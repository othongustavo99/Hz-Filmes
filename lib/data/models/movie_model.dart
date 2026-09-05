import 'package:equatable/equatable.dart';
import '../../core/constants/api_constants.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final bool adult;
  final String? originalLanguage;
  final String? originalTitle;
  final double popularity;

  // Campos extras (usados na página de detalhes)
  final int? runtime;
  final String? tagline;
  final String? status;
  final List<Genre> genres;
  final List<CastMember> cast;

  const MovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genreIds,
    required this.adult,
    this.originalLanguage,
    this.originalTitle,
    required this.popularity,
    this.runtime,
    this.tagline,
    this.status,
    this.genres = const [],
    this.cast = const [],
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Sem título',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? json['first_air_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      adult: json['adult'] as bool? ?? false,
      originalLanguage: json['original_language'] as String?,
      originalTitle: json['original_title'] as String? ?? json['original_name'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      status: json['status'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e))
              .toList() ??
          [],
      cast: (json['credits']?['cast'] as List<dynamic>?)
              ?.map((e) => CastMember.fromJson(e))
              .toList() ??
          [],
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=Sem+Poster';
    }
    return '${ApiConstants.imageBaseUrl}${ApiConstants.posterSize}$posterPath';
  }

  String get backdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return 'https://via.placeholder.com/1280x720?text=Sem+Backdrop';
    }
    return '${ApiConstants.imageBaseUrl}${ApiConstants.backdropSize}$backdropPath';
  }

  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return releaseDate!.split('-').first;
  }

  String get runtimeFormatted {
    if (runtime == null) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        voteAverage,
        voteCount,
        releaseDate,
        genreIds,
        adult,
        originalLanguage,
        originalTitle,
        popularity,
        runtime,
        tagline,
        status,
        genres,
        cast,
      ];
}

// Classes auxiliares
class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class CastMember extends Equatable {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }

  String get profileUrl {
    if (profilePath == null || profilePath!.isEmpty) {
      return 'https://via.placeholder.com/185x278?text=Sem+Foto';
    }
    return '${ApiConstants.imageBaseUrl}${ApiConstants.profileSize}$profilePath';
  }

  @override
  List<Object?> get props => [id, name, character, profilePath];
}