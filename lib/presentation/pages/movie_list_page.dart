import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/movie_repository.dart';
import '../blocs/movie_list/movie_list_bloc.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class MovieListPage extends StatelessWidget {
  final String title;
  final MovieListType type;

  const MovieListPage({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieListBloc(
        movieRepository: context.read<MovieRepository>(),
        type: type,
      )..add(LoadMovieList()),
      child: _MovieListView(title: title),
    );
  }
}

class _MovieListView extends StatefulWidget {
  final String title;

  const _MovieListView({required this.title});

  @override
  State<_MovieListView> createState() => _MovieListViewState();
}

class _MovieListViewState extends State<_MovieListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<MovieListBloc>().add(LoadMoreMovies());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.backgroundDark,
      ),
      body: BlocBuilder<MovieListBloc, MovieListState>(
        builder: (context, state) {
          if (state is MovieListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            );
          }

          if (state is MovieListError) {
            return Center(
              child: Text(
                'Erro: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is MovieListLoaded) {
            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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