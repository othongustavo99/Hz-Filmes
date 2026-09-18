enum MediaCategory {
  movies,
  series,
  animes,
  novelas,
}

extension MediaCategoryX on MediaCategory {
  String get label {
    switch (this) {
      case MediaCategory.movies:
        return 'Filmes';
      case MediaCategory.series:
        return 'Séries';
      case MediaCategory.animes:
        return 'Animes';
      case MediaCategory.novelas:
        return 'Novelas';
    }
  }

  bool get isTv => this != MediaCategory.movies;

  String get mediaTypeParam => isTv ? 'tv' : 'movie';
}
