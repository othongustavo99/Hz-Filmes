import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/movie_list/movie_list_bloc.dart';
import 'movie_list_page.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/home/home_bloc.dart';
import '../widgets/movie_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,

      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar filmes',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(LoadHomeData());
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              color: AppTheme.primaryOrange,
              backgroundColor: AppTheme.surfaceDark,
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadHomeData());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MovieSection(
                      title: 'Em Alta',
                      movies: state.trending,
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MovieListPage(
                              title: 'Em Alta',
                              type: MovieListType.trending,
                            ),
                          ),
                        );
                      },
                    ),
                    MovieSection(
                      title: 'Populares',
                      movies: state.popular,
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MovieListPage(
                              title: 'Populares',
                              type: MovieListType.popular,
                            ),
                          ),
                        );
                      },
                    ),
                    MovieSection(
                      title: 'Melhores Avaliados',
                      movies: state.topRated,
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MovieListPage(
                              title: 'Melhores Avaliados',
                              type: MovieListType.topRated,
                            ),
                          ),
                        );
                      },
                    ),
                    MovieSection(
                      title: 'Em Breve',
                      movies: state.upcoming,
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MovieListPage(
                              title: 'Em Breve',
                              type: MovieListType.upcoming,
                            ),
                          ),
                        );
                      },
                    ),
                    MovieSection(
                      title: 'Em Cartaz',
                      movies: state.nowPlaying,
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MovieListPage(
                              title: 'Em Cartaz',
                              type: MovieListType.nowPlaying,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
