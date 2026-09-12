import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/domain/repositories/movie_repository.dart';
import 'package:hz_filmes/presentation/pages/movie_detail_page.dart';

import '../../data/models/movie_model.dart';
import 'movie_card.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<MovieModel> movies;
  final VoidCallback? onSeeAll;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(color: Color(0xFFF5C518)),
                  ),
                ),
            ],
          ),
        ),

        // Lista horizontal
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: MovieCard(
                  movie: movies[index],
                  onTap: () {
                    ActivityLocalDataSource().addClick(
                      movieId: movies[index].id, // ou movie.id
                      genreIds: movies[index].genreIds,
                    );

                    final movieRepository = context.read<MovieRepository>();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                          movieId: movies[index].id,
                          movieRepository: movieRepository,
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
    );
  }
}
