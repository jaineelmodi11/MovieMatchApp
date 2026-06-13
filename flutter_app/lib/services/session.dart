import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight session: persists the backend userId + a stable device uid.
class Session {
  static const _kUserId = 'userId';
  static const _kUid = 'firebaseUid';
  static const _kName = 'displayName';

  static Future<int?> userId() async =>
      (await SharedPreferences.getInstance()).getInt(_kUserId);

  static Future<String?> displayName() async =>
      (await SharedPreferences.getInstance()).getString(_kName);

  static Future<String> deviceUid() async {
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString(_kUid);
    if (uid == null) {
      uid = 'flutter-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_kUid, uid);
    }
    return uid;
  }

  static Future<void> save({required int userId, required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUserId, userId);
    await prefs.setString(_kName, name);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kName);
  }
}
