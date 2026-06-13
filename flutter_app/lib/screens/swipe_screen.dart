import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../models/swipe_movie.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/swipe_card.dart';

class SwipeScreen extends StatefulWidget {
  final int userId;
  const SwipeScreen({super.key, required this.userId});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();
  List<SwipeMovie> _deck = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final deck = await ApiService.instance.fetchSwipeDeck();
    if (!mounted) return;
    setState(() {
      _deck = deck;
      _loading = false;
    });
  }

  void _record(SwipeMovie m, String direction) {
    ApiService.instance.sendSwipe(userId: widget.userId, movieId: m.id, direction: direction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (r) => AppColors.brand.createShader(r),
                  child: const Text('MovieMatch',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const Spacer(),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _deck.isEmpty
                      ? const _EmptyDeck()
                      : CardSwiper(
                          controller: _controller,
                          cardsCount: _deck.length,
                          numberOfCardsDisplayed: _deck.length < 3 ? _deck.length : 3,
                          isLoop: false,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onSwipe: (prev, curr, direction) {
                            final movie = _deck[prev];
                            if (direction == CardSwiperDirection.right) {
                              _record(movie, 'like');
                            } else if (direction == CardSwiperDirection.left) {
                              _record(movie, 'pass');
                            }
                            return true;
                          },
                          cardBuilder: (context, index, px, py) => SwipeCard(movie: _deck[index]),
                        ),
            ),
            if (!_loading && _deck.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundButton(
                      icon: Icons.close_rounded,
                      color: AppColors.pass,
                      onTap: () => _controller.swipe(CardSwiperDirection.left),
                    ),
                    const SizedBox(width: 40),
                    _RoundButton(
                      icon: Icons.favorite_rounded,
                      color: AppColors.like,
                      onTap: () => _controller.swipe(CardSwiperDirection.right),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 16)],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_outlined, size: 56, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('No movies right now', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Make sure the backend is running.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
