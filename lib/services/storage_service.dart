import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _activeUserKey = 'active_user';
  static const String _statsKey = 'stats';
  static const String _progressKey = 'progress';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Users ---
  Future<List<UserProfile>> getUsers() async {
    if (_prefs == null) return [];
    final usersJson = _prefs!.getStringList(_usersKey) ?? [];
    return usersJson.map((jsonStr) => UserProfile.fromJson(jsonDecode(jsonStr))).toList();
  }

  Future<void> saveUser(UserProfile user) async {
    if (_prefs == null) return;
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs!.setStringList(
        _usersKey, users.map((u) => jsonEncode(u.toJson())).toList());
  }

  Future<void> setActiveUserId(String id) async {
    await _prefs?.setString(_activeUserKey, id);
  }

  String? getActiveUserId() {
    return _prefs?.getString(_activeUserKey);
  }

  // --- Progress ---
  // progressKey_userId_gameId -> int (max unlocked level)
  int getUnlockedLevel(String userId, String gameId) {
    return _prefs?.getInt('${_progressKey}_${userId}_$gameId') ?? 1;
  }

  Future<void> setUnlockedLevel(String userId, String gameId, int level) async {
    final current = getUnlockedLevel(userId, gameId);
    if (level > current) {
      await _prefs?.setInt('${_progressKey}_${userId}_$gameId', level);
    }
  }

  // --- Stats ---
  // statsKey_userId -> List of Map containing score history
  Future<void> addStatRecord(String userId, Map<String, dynamic> record) async {
    final key = '${_statsKey}_$userId';
    final recordsJson = _prefs?.getStringList(key) ?? [];
    recordsJson.add(jsonEncode(record));
    await _prefs?.setStringList(key, recordsJson);
  }

  List<Map<String, dynamic>> getStats(String userId) {
    final key = '${_statsKey}_$userId';
    final recordsJson = _prefs?.getStringList(key) ?? [];
    return recordsJson.map((str) => jsonDecode(str) as Map<String, dynamic>).toList();
  }
}
