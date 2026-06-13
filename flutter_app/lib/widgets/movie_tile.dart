import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import 'poster_image.dart';

class MovieTile extends StatelessWidget {
  final Movie movie;
  const MovieTile({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.tile),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PosterImage(url: movie.posterUrl),
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.posterScrim)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movie.topGenre != null) GenreChip(text: movie.topGenre!.toUpperCase()),
                const SizedBox(height: 4),
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (movie.voteAverage != null)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(movie.voteAverage!.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
