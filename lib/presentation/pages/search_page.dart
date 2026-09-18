import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/core/constants/media_category.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/datasources/remote/activity_remote_datasource.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/repositories/movie_repository.dart';
import '../blocs/search/search_bloc.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final movieRepository = context.read<MovieRepository>();

    return BlocProvider(
      create: (context) => SearchBloc(movieRepository),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  MediaCategory _selectedCategory = MediaCategory.movies;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(
        LoadMoreSearchResults(),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onSearch(String value) {
    context.read<SearchBloc>().add(
      SearchMovies(
        value,
        category: _selectedCategory,
      ),
    );
  }

  void _changeCategory(MediaCategory category) {
    if (_selectedCategory == category) return;

    setState(() {
      _selectedCategory = category;
    });

    // Se já existe uma pesquisa, refaz automaticamente
    // para a nova categoria.
    if (_controller.text.trim().isNotEmpty) {
      context.read<SearchBloc>().add(
        SearchMovies(
          _controller.text,
          category: category,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,

      appBar: AppBar(
        title: const Text('Buscar'),
        backgroundColor: AppTheme.backgroundDark,
      ),

      body: Column(
        children: [
          // ==================== CATEGORIAS ====================
          SizedBox(
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
                    onTap: () => _changeCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryOrange
                              : Colors.white24,
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

          // ==================== CAMPO DE BUSCA ====================
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar ${_selectedCategory.label.toLowerCase()}...',
                hintStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          _controller.clear();

                          context.read<SearchBloc>().add(
                            ClearSearch(),
                          );

                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _onSearch,
            ),
          ),

          // ==================== RESULTADOS ====================
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
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
                              Icons.search,
                              size: 48,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Buscar ${_selectedCategory.label.toLowerCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Digite um nome para começar a buscar',
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

                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryOrange,
                    ),
                  );
                }

                if (state is SearchError) {
                  return Center(
                    child: Text(
                      'Erro ao buscar: ${state.message}',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (state is SearchEmpty) {
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
                              Icons.movie_filter_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nenhum resultado para "${state.query}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum resultado encontrado em '
                            '${_selectedCategory.label}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is SearchLoaded) {
                  return GridView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: state.hasReachedMax
                        ? state.movies.length
                        : state.movies.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.movies.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryOrange,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      final movie = state.movies[index];

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
                                movieRepository: context
                                    .read<MovieRepository>(),
                                isTv: state.category.isTv,
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
          ),
        ],
      ),
    );
  }
}
