import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../widgets/movie_card.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';
import '../blocs/movie_detail/movie_detail_bloc.dart';

class MovieDetailPage extends StatelessWidget {
  final int movieId;
  final MovieRepository movieRepository;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.movieRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MovieDetailBloc(movieRepository)..add(LoadMovieDetail(movieId)),
      child: const _MovieDetailView(),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailLoaded) {
            return _MovieDetailContent(
              movie: state.movie,
              similarMovies: state.similarMovies,
            );
          }

          if (state is MovieDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao carregar detalhes',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          if (state is MovieDetailLoaded) {
            return _MovieDetailContent(movie: state.movie);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MovieDetailContent extends StatelessWidget {
  final MovieModel movie;
  final List<MovieModel> similarMovies;

  const _MovieDetailContent({
    required this.movie,
    this.similarMovies = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // AppBar com Backdrop + Botão de Favorito
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppTheme.backgroundDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favState) {
                bool isFavorite = false;
                if (favState is FavoritesLoaded) {
                  isFavorite = favState.isFavorite(movie.id);
                }

                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite ? AppTheme.primaryOrange : Colors.white,
                  ),
                  onPressed: () {
                    context.read<FavoritesBloc>().add(ToggleFavorite(movie));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Removido da Minha Lista'
                              : 'Adicionado à Minha Lista',
                        ),
                        backgroundColor: AppTheme.surfaceDark,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: AppTheme.primaryOrange,
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: movie.backdropUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppTheme.cardDark),
                  errorWidget: (context, url, error) =>
                      Container(color: AppTheme.cardDark),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.backgroundDark.withOpacity(0.7),
                        AppTheme.backgroundDark,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Conteúdo
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster + Infos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppTheme.primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                ' / 10',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            [
                              if (movie.year.isNotEmpty) movie.year,
                              if (movie.runtimeFormatted.isNotEmpty)
                                movie.runtimeFormatted,
                            ].join(' • '),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (movie.genres.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: movie.genres.take(4).map((genre) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardDark,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    genre.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tagline
                if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                  Text(
                    '"${movie.tagline}"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Sinopse
                const Text(
                  'Sinopse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview?.isNotEmpty == true
                      ? movie.overview!
                      : 'Sinopse não disponível.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // Elenco
                if (movie.cast.isNotEmpty) ...[
                  const Text(
                    'Elenco Principal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movie.cast.take(12).length,
                      itemBuilder: (context, index) {
                        final actor = movie.cast[index];
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: actor.profileUrl,
                                  width: 100,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: AppTheme.cardDark,
                                        highlightColor: AppTheme.surfaceDark,
                                        child: Container(
                                          color: AppTheme.cardDark,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: AppTheme.cardDark,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                actor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (actor.character != null)
                                Text(
                                  actor.character!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Filmes Semelhantes
                if (similarMovies.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Filmes Semelhantes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: similarMovies.length,
                      itemBuilder: (context, index) {
                        final similarMovie = similarMovies[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 10),
                          child: MovieCard(
                            movie: similarMovie,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailPage(
                                    movieId: similarMovie.id,
                                    movieRepository: context
                                        .read<MovieRepository>(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
