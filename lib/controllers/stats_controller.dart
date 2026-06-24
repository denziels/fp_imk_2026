import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';

class StatsController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  final RxList<Map<String, dynamic>> records = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.activeUser, (_) => _loadStats());
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _auth.activeUser.value;
    if (user == null) {
      records.clear();
      return;
    }

    try {
      final response = await http.get(Uri.parse('${_auth.apiUrl}stats.php?child_id=${user.id}'));
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        final List<dynamic> loaded = data['data'];
        records.assignAll(loaded.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (e) {
      print("Load Stats Error: $e");
    }
  }

  Future<void> recordGameResult({
    required String gameId,
    required String gameName,
    required int level,
    required bool isSuccess,
    required String details,
  }) async {
    final user = _auth.activeUser.value;
    if (user == null) return;

    final record = {
      'gameId': gameId,
      'gameName': gameName,
      'level': level,
      'isSuccess': isSuccess,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Optimistic UI update
    records.add(record);

    try {
      await http.post(
        Uri.parse('${_auth.apiUrl}stats.php'),
        body: jsonEncode({
          'child_id': user.id,
          'game_id': gameId,
          'game_name': gameName,
          'level': level,
          'is_success': isSuccess,
          'details': details,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Save Stat Error: $e");
    }
  }
}
