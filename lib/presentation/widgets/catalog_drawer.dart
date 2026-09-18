import 'package:flutter/material.dart';

import 'package:hz_filmes/core/constants/genre_catalog.dart';
import 'package:hz_filmes/core/constants/media_category.dart';
import 'package:hz_filmes/core/theme/app_theme.dart';
import 'package:hz_filmes/presentation/pages/genre_list_page.dart';

class CatalogDrawer extends StatelessWidget {
  const CatalogDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            // ==================== HEADER ====================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
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
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Catálogo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: Colors.white12,
              height: 1,
            ),

            // ==================== CATÁLOGOS ====================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  _buildSection(
                    context,
                    title: 'FILMES',
                    category: MediaCategory.movies,
                  ),

                  _buildDivider(),

                  _buildSection(
                    context,
                    title: 'SÉRIES',
                    category: MediaCategory.series,
                  ),

                  _buildDivider(),

                  _buildSection(
                    context,
                    title: 'ANIMES',
                    category: MediaCategory.animes,
                  ),

                  _buildDivider(),

                  _buildSection(
                    context,
                    title: 'NOVELAS',
                    category: MediaCategory.novelas,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required MediaCategory category,
  }) {
    final genres = GenreCatalog.forCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.primaryOrange,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: genres.map((genre) {
            return _buildGenreButton(
              context,
              genre: genre,
              category: category,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenreButton(
    BuildContext context, {
    required GenreItem genre,
    required MediaCategory category,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenreListPage(
              title: genre.name,
              category: category,
              genreId: genre.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: Text(
          genre.name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        color: Colors.white12,
        height: 1,
      ),
    );
  }
}
