import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/media_category.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/movie_list/movie_list_bloc.dart';
import '../widgets/featured_banner.dart';
import '../widgets/home_loading.dart';
import '../widgets/movie_section.dart';
import 'movie_list_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;

  const HomePage({
    super.key,
    this.onSearchTap,
    this.onMenuTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaCategory _selectedCategory = MediaCategory.movies;

  void _onCategoryChanged(MediaCategory category) {
    if (_selectedCategory == category) return;

    setState(() {
      _selectedCategory = category;
    });

    context.read<HomeBloc>().add(LoadHomeData(category: category));
  }

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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(
                          LoadHomeData(category: _selectedCategory),
                        );
                      },
                      child: const Text('Tentar novamente'),
                    ),
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
                context.read<HomeBloc>().add(
                  LoadHomeData(category: _selectedCategory),
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ==================== APP BAR ====================
                  SliverAppBar(
                    floating: false,
                    snap: false,
                    pinned: false,
                    backgroundColor: AppTheme.backgroundDark,
                    elevation: 0,
                    title: Row(
                      children: [
                        IconButton(
                          onPressed: widget.onMenuTap,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 12),

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
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: widget.onSearchTap,
                      ),
                    ],
                  ),

                  // ==================== ABAS ====================
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        children: MediaCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _onCategoryChanged(category),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.surfaceDark, // mesma cor sempre
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme
                                              .primaryOrange // borda laranja selecionado
                                        : Colors.white24, // borda suave quando não
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  category.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.primaryOrange
                                        : Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // ==================== CONTEÚDO ====================
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeaturedBanner(
                          movies: state.trending.isNotEmpty
                              ? state.trending
                              : state.popular,
                          isTv: _selectedCategory.isTv,
                        ),

                        // ==================== SEÇÕES COMUNS ====================
                        MovieSection(
                          title: 'Em Alta',
                          movies: state.trending,
                          isTv: _selectedCategory.isTv,
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieListPage(
                                  title: 'Em Alta',
                                  type: MovieListType.trending,
                                  category: _selectedCategory,
                                ),
                              ),
                            );
                          },
                        ),

                        if (state.recommended.isNotEmpty)
                          MovieSection(
                            title: 'Recomendados para você',
                            movies: state.recommended,
                            isTv: _selectedCategory.isTv,
                          ),

                        MovieSection(
                          title: 'Populares',
                          movies: state.popular,
                          isTv: _selectedCategory.isTv,
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieListPage(
                                  title: 'Populares',
                                  type: MovieListType.popular,
                                  category: _selectedCategory,
                                ),
                              ),
                            );
                          },
                        ),

                        MovieSection(
                          title: 'Melhores Avaliados',
                          movies: state.topRated,
                          isTv: _selectedCategory.isTv,
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieListPage(
                                  title: 'Melhores Avaliados',
                                  type: MovieListType.topRated,
                                  category: _selectedCategory,
                                ),
                              ),
                            );
                          },
                        ),

                        // ==================== EM BREVE ====================
                        MovieSection(
                          title: 'Em breve',
                          movies: state.upcoming,
                          isTv: _selectedCategory.isTv,
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieListPage(
                                  title: 'Em breve',
                                  type: MovieListType.upcoming,
                                  category: _selectedCategory,
                                ),
                              ),
                            );
                          },
                        ),

                        // ==================== SEÇÕES ESPECÍFICAS DE NOVELAS ====================
                        if (_selectedCategory == MediaCategory.novelas) ...[
                          MovieSection(
                            title: 'Novelas Brasileiras',
                            movies: state.brazilianNovelas,
                            isTv: true,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieListPage(
                                    title: 'Novelas Brasileiras',
                                    type: MovieListType.brazilianNovelas,
                                    category: MediaCategory.novelas,
                                  ),
                                ),
                              );
                            },
                          ),
                          MovieSection(
                            title: '2000s',
                            movies: state.novelas2000s,
                            isTv: true,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieListPage(
                                    title: '2000s',
                                    type: MovieListType.novelas2000s,
                                    category: MediaCategory.novelas,
                                  ),
                                ),
                              );
                            },
                          ),
                          MovieSection(
                            title: '90s',
                            movies: state.novelas90s,
                            isTv: true,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieListPage(
                                    title: '90s',
                                    type: MovieListType.novelas90s,
                                    category: MediaCategory.novelas,
                                  ),
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          MovieSection(
                            title: 'Em Cartaz',
                            movies: state.nowPlaying,
                            isTv: _selectedCategory.isTv,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieListPage(
                                    title: 'Em Cartaz',
                                    type: MovieListType.nowPlaying,
                                    category: _selectedCategory,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

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
