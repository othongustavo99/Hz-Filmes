import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/datasources/remote/activity_remote_datasource.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/repositories/movie_repository.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Minha Lista'),
        backgroundColor: AppTheme.backgroundDark,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            );
          }

          if (state is FavoritesError) {
            return Center(
              child: Text(
                'Erro: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          size: 48,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Sua lista está vazia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no ícone de favorito nos filmes\npara salvá-los aqui',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final movie = state.favorites[index];
                return MovieCard(
                  movie: movie,
                  onTap: () {
                    ActivityLocalDataSource().addClick(
                      movieId: movie.id,
                      genreIds: movie.genreIds,
                    );
                    ActivityRemoteDataSource().addClick(movie.id);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                          movieId: movie.id,
                          movieRepository: context.read<MovieRepository>(),
                          
                          
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
