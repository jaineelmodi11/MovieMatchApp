class Genre {
  final int id;
  final String name;
  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: (json['id'] ?? 0) as int, name: (json['name'] ?? '') as String);
}

class Movie {
  final int id;
  final String title;
  final String? overview;
  final double? voteAverage;
  final String? posterPath;
  final String? posterUrlFull; // when backend already sends a full URL
  final List<Genre> genres;

  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.voteAverage,
    this.posterPath,
    this.posterUrlFull,
    this.genres = const [],
  });

  String? get posterUrl {
    if (posterUrlFull != null && posterUrlFull!.isNotEmpty) return posterUrlFull;
    if (posterPath != null && posterPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return null;
  }

  String? get topGenre => genres.isNotEmpty ? genres.first.name : null;

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawVote = json['voteAverage'] ?? json['vote_average'];
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      overview: json['overview'] as String?,
      voteAverage: rawVote == null ? null : (rawVote as num).toDouble(),
      posterPath: (json['posterPath'] ?? json['poster_path']) as String?,
      posterUrlFull: json['posterURL'] as String?,
      genres: (json['genres'] as List?)
              ?.map((g) => Genre.fromJson(g as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
