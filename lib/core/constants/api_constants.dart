class ApiConstants {
  
  static const String apiKey = '3fb520ec1865d9c239702b3be923c20c';
  
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String backendBaseUrl = 'http://192.168.0.2:3000';
  
  
  // Tamanhos de imagem comuns
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';

  // Endpoints principais
  static const String trendingMovies = '/trending/movie/week';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String nowPlaying = '/movie/now_playing';
  static const String searchMovie = '/search/movie';
  static const String movieDetails = '/movie'; // + /{id}
}