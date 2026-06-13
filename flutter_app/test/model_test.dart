import 'package:flutter_test/flutter_test.dart';
import 'package:moviematch/models/movie.dart';
import 'package:moviematch/models/swipe_movie.dart';

void main() {
  test('SwipeMovie parses backend /movies shape', () {
    final m = SwipeMovie.fromJson({'id': 1, 'title': 'A', 'posterURL': 'https://x/p.jpg'});
    expect(m.id, 1);
    expect(m.posterUrl, 'https://x/p.jpg');
  });

  test('Movie builds poster URL from snake_case poster_path', () {
    final m = Movie.fromJson({'id': 550, 'title': 'Fight Club', 'poster_path': '/p.jpg', 'vote_average': 8.4});
    expect(m.posterUrl, 'https://image.tmdb.org/t/p/w500/p.jpg');
    expect(m.voteAverage, 8.4);
  });

  test('Movie reads genres list', () {
    final m = Movie.fromJson({
      'id': 1,
      'title': 'X',
      'genres': [
        {'id': 18, 'name': 'Drama'}
      ]
    });
    expect(m.topGenre, 'Drama');
  });
}
