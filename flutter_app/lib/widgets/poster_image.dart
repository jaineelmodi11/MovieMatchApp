import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PosterImage extends StatelessWidget {
  final String? url;
  final double? height;
  const PosterImage({super.key, required this.url, this.height});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        height: height,
        color: AppColors.surfaceAlt,
        child: const Center(child: Icon(Icons.movie_outlined, color: AppColors.textSecondary)),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (c, _) => Container(color: AppColors.surfaceAlt),
      errorWidget: (c, _, __) => Container(
        color: AppColors.surfaceAlt,
        child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textSecondary)),
      ),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String text;
  const GenreChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
