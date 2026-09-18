import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieCard extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final bool isTv;
  final MovieRepository? movieRepository;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.isTv = false,
    this.movieRepository,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  Future<MovieModel?>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(covariant MovieCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.movie.id != widget.movie.id ||
        oldWidget.isTv != widget.isTv) {
      _loadDetails();
    }
  }

  void _loadDetails() {
    if (widget.isTv && widget.movieRepository != null) {
      _detailsFuture = _fetchDetails();
    } else {
      _detailsFuture = null;
    }
  }

  Future<MovieModel?> _fetchDetails() async {
    try {
      return await widget.movieRepository!.getDetails(
        widget.movie.id,
        isTv: true,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== POSTER ====================
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: widget.movie.posterUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppTheme.cardDark,
                  highlightColor: AppTheme.surfaceDark,
                  child: Container(
                    color: AppTheme.cardDark,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.cardDark,
                  child: const Icon(
                    Icons.movie,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ==================== TÍTULO ====================
          Text(
            widget.movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // ==================== NOTA + ANO ====================
          Row(
            children: [
              const Icon(
                Icons.star,
                color: AppTheme.primaryOrange,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                widget.movie.voteAverage.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (widget.movie.year.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  widget.movie.year,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),

          // ==================== TEMPORADAS + EPISÓDIOS ====================
          if (widget.isTv)
            FutureBuilder<MovieModel?>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                final details = snapshot.data;

                if (details == null) {
                  return const SizedBox(height: 18);
                }

                final seasons = details.numberOfSeasons;
                final episodes = details.numberOfEpisodes;

                if (seasons == null && episodes == null) {
                  return const SizedBox(height: 18);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    children: [
                      if (seasons != null) ...[
                        const Icon(
                          Icons.layers_outlined,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$seasons ${seasons == 1 ? 'temp.' : 'temps.'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                      if (seasons != null && episodes != null)
                        const SizedBox(width: 7),
                      if (episodes != null) ...[
                        const Icon(
                          Icons.play_circle_outline,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$episodes ${episodes == 1 ? 'ep.' : 'eps.'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
