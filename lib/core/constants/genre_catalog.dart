import 'media_category.dart';

class GenreItem {
  final int id;
  final String name;

  const GenreItem(this.id, this.name);
}

class GenreCatalog {
  /// Gêneros de FILMES (TMDB)
  static const List<GenreItem> movies = [
    GenreItem(28, 'Ação'),
    GenreItem(12, 'Aventura'),
    GenreItem(35, 'Comédia'),
    GenreItem(18, 'Drama'),
    GenreItem(10749, 'Romance'),
    GenreItem(27, 'Terror'),
    GenreItem(878, 'Ficção'),
    GenreItem(53, 'Thriller'),
    GenreItem(80, 'Crime'),
    GenreItem(16, 'Animação'),
    GenreItem(10751, 'Família'),
    GenreItem(14, 'Fantasia'),
    GenreItem(99, 'Documentário'),
    GenreItem(10752, 'Guerra'),
    GenreItem(37, 'Faroeste'),
  ];

  /// Gêneros de SÉRIES (TMDB TV)
  static const List<GenreItem> series = [
    GenreItem(10759, 'Ação e Aventura'),
    GenreItem(35, 'Comédia'),
    GenreItem(18, 'Drama'),
    GenreItem(80, 'Crime'),
    GenreItem(9648, 'Mistério'),
    GenreItem(10765, 'Sci-Fi & Fantasia'),
    GenreItem(10764, 'Reality'),
    GenreItem(10762, 'Kids'),
    GenreItem(99, 'Documentário'),
    GenreItem(10768, 'Guerra e Política'),
  ];

  /// Subfiltros de ANIMES
  static const List<GenreItem> animes = [
    GenreItem(16, 'Todos'),
    GenreItem(10759, 'Ação'),
    GenreItem(35, 'Comédia'),
    GenreItem(18, 'Drama'),
    GenreItem(14, 'Fantasia'),
    GenreItem(10765, 'Sci-Fi'),
    GenreItem(9648, 'Mistério'),
    GenreItem(10749, 'Romance'),
    GenreItem(10762, 'Kids'),
  ];

  /// Gêneros de NOVELAS
  static const List<GenreItem> novelas = [
    GenreItem(10766, 'Todas'),
    GenreItem(18, 'Drama'),
    GenreItem(10749, 'Romance'),
  ];

  static List<GenreItem> forCategory(MediaCategory category) {
    switch (category) {
      case MediaCategory.movies:
        return movies;

      case MediaCategory.series:
        return series;

      case MediaCategory.animes:
        return animes;

      case MediaCategory.novelas:
        return novelas;
    }
  }
}