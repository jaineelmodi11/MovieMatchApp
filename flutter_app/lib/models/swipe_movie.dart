class SwipeMovie {
  final int id;
  final String title;
  final String posterUrl;

  const SwipeMovie({required this.id, required this.title, required this.posterUrl});

  factory SwipeMovie.fromJson(Map<String, dynamic> json) {
    return SwipeMovie(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      posterUrl: (json['posterURL'] ?? '') as String,
    );
  }
}
