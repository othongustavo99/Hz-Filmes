import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/core/constants/media_category.dart';
import 'package:hz_filmes/core/theme/app_theme.dart';
import 'package:hz_filmes/domain/repositories/movie_repository.dart';
import 'package:hz_filmes/presentation/blocs/movie_list/movie_list_bloc.dart';
import 'package:hz_filmes/presentation/widgets/movie_card.dart';
import 'package:hz_filmes/presentation/pages/movie_detail_page.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/datasources/remote/activity_remote_datasource.dart';

class GenreListPage extends StatelessWidget {
  final String title;
  final MediaCategory category;
  final int genreId;

  const GenreListPage({
    super.key,
    required this.title,
    required this.category,
    required this.genreId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieListBloc(
        movieRepository: context.read<MovieRepository>(),
        type: MovieListType.popular, // placeholder
        category: category,
        genreId: genreId, // vamos adicionar isso no bloc
      )..add(LoadMovieList()),
      child: _GenreListView(
        title: title,
        isTv: category.isTv,
      ),
    );
  }
}

class _GenreListView extends StatefulWidget {
  final String title;
  final bool isTv;

  const _GenreListView({required this.title, required this.isTv});

  @override
  State<_GenreListView> createState() => _GenreListViewState();
}

class _GenreListViewState extends State<_GenreListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent * 0.9) {
        context.read<MovieListBloc>().add(LoadMoreMovies());
      }
    });
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
                state.message,
                style: const TextStyle(color: Colors.white),
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

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(
                          movieId: movie.id,
                          movieRepository: context.read<MovieRepository>(),
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
