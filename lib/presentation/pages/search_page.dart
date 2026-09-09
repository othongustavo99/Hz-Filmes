import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    context.read<SearchBloc>().add(SearchMovies(value));
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
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar filmes...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchBloc>().add(ClearSearch());
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
                setState(() {}); // Atualiza o botão de limpar
              },
              onSubmitted: _onSearch,
            ),
          ),

          // Resultados
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return const Center(
                    child: Text(
                      'Digite o nome de um filme para buscar',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                  );
                }

                if (state is SearchError) {
                  return Center(
                    child: Text(
                      'Erro ao buscar: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (state is SearchEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${state.query}"',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                if (state is SearchLoaded) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.movies.length,
                    itemBuilder: (context, index) {
                      final movie = state.movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () {
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
          ),
        ],
      ),
    );
  }
}