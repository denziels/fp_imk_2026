import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';
import '../controllers/progress_controller.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatsController stats = Get.find<StatsController>();
    final ProgressController progress = Get.find<ProgressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Belajar Anak'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Progres Level Terbuka', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Obx(() => _buildProgressGrid(progress)),
            const SizedBox(height: 32),
            const Text('Riwayat Permainan Terakhir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Obx(() {
              final records = stats.records.reversed.take(10).toList();
              if (records.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('Belum ada riwayat permainan.')),
                  ),
                );
              }
              return Column(
                children: records.map((record) => _buildHistoryCard(record)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressGrid(ProgressController progress) {
    final games = {
      'tracing': 'Menebalkan',
      'writing': 'Menulis',
      'spelling': 'Mengeja',
      'word_search': 'Cari Kata',
      'tidy_up': 'Beres-beres',
      'reading': 'Membaca',
    };

    final maxLevels = {
      'tracing': 3,
      'writing': 3,
      'spelling': 3,
      'word_search': 3,
      'tidy_up': 2,
      'reading': 4,
    };

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: games.entries.map((e) {
        final rawLevel = progress.unlockedLevels[e.key] ?? 1;
        final maxLevel = maxLevels[e.key] ?? 1;
        final level = rawLevel > maxLevel ? maxLevel : rawLevel;
        return Card(
          color: const Color(0xFFC7E5C4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Level Terbuka: $level', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final bool isSuccess = record['isSuccess'] ?? false;
    final date = DateTime.parse(record['timestamp'] ?? DateTime.now().toIso8601String());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSuccess ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          child: Icon(
            isSuccess ? Icons.check : Icons.close,
            color: isSuccess ? Colors.green : Colors.red,
          ),
        ),
        title: Text('${record['gameName']} - Level ${record['level']}'),
        subtitle: Text(record['details']),
        trailing: Text('${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
      ),
    );
  }
}
