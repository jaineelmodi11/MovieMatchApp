import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../models/swipe_movie.dart';

/// Backend base URL. Override at build time:
///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000   (Android emulator)
const String kBackendBaseUrl =
    String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:3000');

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Uri _u(String path) => Uri.parse('$kBackendBaseUrl$path');

  Future<int?> importOrGetUser({required String uid, required String name}) async {
    try {
      final res = await http.post(
        _u('/users/importOrGetId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebaseUid': uid, 'displayName': name}),
      );
      if (res.statusCode == 200) {
        return (jsonDecode(res.body)['userId']) as int?;
      }
    } catch (_) {}
    return null;
  }

  Future<List<SwipeMovie>> fetchSwipeDeck() async {
    try {
      final res = await http.get(_u('/movies'));
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((m) => SwipeMovie.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> sendSwipe({
    required int userId,
    required int movieId,
    required String direction,
  }) async {
    try {
      final res = await http.post(
        _u('/swipes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'movieId': movieId, 'direction': direction}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// kind = content | cf | hybrid
  Future<List<Movie>> fetchRecommendations({required int userId, required String kind}) async {
    try {
      final res = await http.get(_u('/recommendations/$kind/$userId'));
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((m) => Movie.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Movie>> fetchLikedMovies({required int userId}) async {
    try {
      final res = await http.get(_u('/users/$userId/likes'));
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((m) => Movie.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
