import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/movie_list/movie_list_bloc.dart';
import 'movie_list_page.dart';
import '../widgets/featured_banner.dart';
import '../widgets/home_loading.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/home/home_bloc.dart';
import '../widgets/movie_section.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const HomePage({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const HomeLoadingShimmer();
          }

          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ... seu empty/error state atual
                  ],
                ),
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
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: false, // não volta ao rolar um pouco pra cima
                    snap: false, // não “pula” de volta
                    pinned: false, // não fica fixa
                    backgroundColor: AppTheme.backgroundDark,
                    elevation: 0,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'HZ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Filmes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: onSearchTap,
                      ),
                    ],
                  ),
                  // Conteúdo das seções
                  SliverToBoxAdapter(
                    // ⚠️ corrija para SliverToBoxAdapter
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeaturedBanner(
                          movies: state.trending.isNotEmpty
                              ? state.trending
                              : state.popular,
                        ),

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
                        if (state.recommended.isNotEmpty)
                          MovieSection(
                            title: 'Recomendados para você',
                            movies: state.recommended,
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
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
