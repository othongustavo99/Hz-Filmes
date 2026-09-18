import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/data/datasources/remote/activity_remote_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';
import '../../domain/repositories/movie_repository.dart';
import '../pages/movie_detail_page.dart';

class FeaturedBanner extends StatefulWidget {
  final List<MovieModel> movies;
  final bool isTv;

  const FeaturedBanner({
    super.key,
    required this.movies,
    this.isTv = false,
  });

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  late final PageController _pageController;
  static const int _initialPage = 1000;
  static const String _cacheKey = 'featured_banner_movies';
  static const String _dateKey = 'featured_banner_date';

  int _currentPage = 0;
  List<MovieModel> _featuredMovies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _loadFeaturedMovies();
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadFeaturedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_dateKey);
    final today = _today();

    // Mesmo dia → tenta usar o cache
    if (savedDate == today) {
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        try {
          final List<dynamic> ids = jsonDecode(cached);
          final idSet = ids.map((e) => e as int).toList();

          final fromCache = <MovieModel>[];
          for (final id in idSet) {
            final match = widget.movies.where((m) => m.id == id);
            if (match.isNotEmpty) {
              fromCache.add(match.first);
            }
          }

          if (fromCache.length >= 3) {
            setState(() {
              _featuredMovies = fromCache;
              _loading = false;
            });
            return;
          }
        } catch (_) {
          // se der erro no cache, segue pro fluxo normal
        }
      }
    }

    // Dia novo (ou cache inválido) → pega 7 novos e salva
    final selected = widget.movies.take(7).toList();
    final ids = selected.map((m) => m.id).toList();

    await prefs.setString(_cacheKey, jsonEncode(ids));
    await prefs.setString(_dateKey, today);

    if (!mounted) return;
    setState(() {
      _featuredMovies = selected;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 240);
    }

    final movies = _featuredMovies;
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index % movies.length;
              });
            },
            itemBuilder: (context, index) {
              final movie = movies[index % movies.length];
              return GestureDetector(
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
                        movieRepository: context.read<MovieRepository>(),
                        isTv: widget.isTv,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: movie.backdropUrl.isNotEmpty
                              ? movie.backdropUrl
                              : movie.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppTheme.cardDark),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.cardDark,
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white24,
                              size: 48,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppTheme.primaryOrange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (movie.year.isNotEmpty) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      movie.year,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(movies.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryOrange
                    : AppTheme.textSecondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
