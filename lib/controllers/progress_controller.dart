import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';

class ProgressController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  // Rx map to dynamically observe changes
  final RxMap<String, int> unlockedLevels = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // React to user change
    ever(_auth.activeUser, (_) => _loadProgress());
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = _auth.activeUser.value;
    if (user == null) {
      unlockedLevels.clear();
      return;
    }

    try {
      final response = await http.get(Uri.parse('${_auth.apiUrl}progress.php?child_id=${user.id}'));
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        final progressData = data['data'] as Map<String, dynamic>;
        
        final games = ['tracing', 'writing', 'spelling', 'word_search', 'tidy_up', 'reading'];
        for (var game in games) {
          unlockedLevels[game] = progressData[game] ?? 1;
        }
      }
    } catch (e) {
      print("Load Progress Error: $e");
    }
  }

  bool isLevelUnlocked(String gameId, int level) {
    return (unlockedLevels[gameId] ?? 1) >= level;
  }

  Future<void> completeLevel(String gameId, int completedLevel) async {
    final user = _auth.activeUser.value;
    if (user == null) return;

    final nextLevel = completedLevel + 1;
    final currentUnlocked = unlockedLevels[gameId] ?? 1;

    if (nextLevel > currentUnlocked) {
      // Update local UI state immediately for responsive feel
      unlockedLevels[gameId] = nextLevel;
      
      try {
        await http.post(
          Uri.parse('${_auth.apiUrl}progress.php'),
          body: jsonEncode({
            'child_id': user.id,
            'game_id': gameId,
            'level': nextLevel,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print("Save Progress Error: $e");
      }
    }
  }
}
