import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_tile.dart';

class RecommendationsScreen extends StatefulWidget {
  final int userId;
  const RecommendationsScreen({super.key, required this.userId});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  static const _engines = {'content': 'Content', 'cf': 'Collaborative', 'hybrid': 'Hybrid'};
  String _engine = 'content';
  List<Movie> _recs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final recs = await ApiService.instance.fetchRecommendations(userId: widget.userId, kind: _engine);
    if (!mounted) return;
    setState(() {
      _recs = recs;
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
            const Text('Recommended for You',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('Tuned to your swipes', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Row(
              children: _engines.entries.map((e) {
                final selected = e.key == _engine;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _engine = e.key);
                      _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.brand : null,
                        color: selected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(e.value,
                          style: TextStyle(
                              color: selected ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _recs.isEmpty
                      ? const Center(
                          child: Text('No recommendations yet — swipe a few movies first.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.62,
                            ),
                            itemCount: _recs.length,
                            itemBuilder: (c, i) => MovieTile(movie: _recs[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
