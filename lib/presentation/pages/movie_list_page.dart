import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/core/constants/media_category.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/datasources/remote/activity_remote_datasource.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/repositories/movie_repository.dart';
import '../blocs/movie_list/movie_list_bloc.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class MovieListPage extends StatelessWidget {
  final String title;
  final MovieListType type;
  final MediaCategory category;

  const MovieListPage({
    super.key,
    required this.title,
    required this.type,
    this.category = MediaCategory.movies,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieListBloc(
        movieRepository: context.read<MovieRepository>(),
        type: type,
        category: category,
      )..add(LoadMovieList()),
      child: _MovieListView(
        title: title,
        isTv: category.isTv,
      ),
    );
  }
}

class _MovieListView extends StatefulWidget {
  final String title;
  final bool isTv;

  const _MovieListView({
    required this.title,
    required this.isTv,
  });

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
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
              itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.movies.length) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryOrange,
                    ),
                  );
                }

                final movie = state.movies[index];

                return MovieCard(
                  movie: movie,
                  isTv: widget.isTv,
                  movieRepository: context.read<MovieRepository>(),
                  onTap: () {
                    ActivityLocalDataSource().addClick(
                      movieId: movie.id,
                      genreIds: movie.genreIds,
                    );
                    ActivityRemoteDataSource().addClick(movie.id);

                    final movieRepository = context.read<MovieRepository>();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                          movieId: movie.id,
                          movieRepository: movieRepository,
                          isTv: widget.isTv,
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
