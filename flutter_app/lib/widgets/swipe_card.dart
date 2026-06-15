import 'package:flutter/material.dart';
import '../models/swipe_movie.dart';
import '../theme/app_theme.dart';
import 'poster_image.dart';

class SwipeCard extends StatelessWidget {
  final SwipeMovie movie;
  const SwipeCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withAlpha(64), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(url: movie.posterUrl),
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.posterScrim)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
