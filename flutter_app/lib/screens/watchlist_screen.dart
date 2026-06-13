import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_tile.dart';

class WatchlistScreen extends StatefulWidget {
  final int userId;
  const WatchlistScreen({super.key, required this.userId});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Movie> _liked = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final liked = await ApiService.instance.fetchLikedMovies(userId: widget.userId);
    if (!mounted) return;
    setState(() {
      _liked = liked;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Your Likes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const Spacer(),
                if (!_loading)
                  Text('${_liked.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _liked.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite_border_rounded, size: 56, color: AppColors.textSecondary),
                              SizedBox(height: 12),
                              Text('No likes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('Swipe right on movies you love.', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.62,
                            ),
                            itemCount: _liked.length,
                            itemBuilder: (c, i) => MovieTile(movie: _liked[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
