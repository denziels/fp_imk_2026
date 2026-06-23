import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shared_background.dart';
import 'story_screen.dart';
import 'reading_screen.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';

class ReadingLevelScreen extends StatelessWidget {
  const ReadingLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          child: WhiteCardContainer(
            badgeText: 'Pilih Level',
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar with Back and Volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                      const TTSAudioButtons(
                      textToSpeak: "Pilih level membaca!",
                      iconSize: 40.0,
                    ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Grid of 4 levels
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildLevelCard(
                        level: 'Level 1',
                        title: 'Huruf',
                        icon: Icons.abc,
                        color: Colors.redAccent,
                        onTap: () => Get.to(() => const ReadingScreen(level: 1)),
                      ),
                      _buildLevelCard(
                        level: 'Level 2',
                        title: 'Suku Kata',
                        icon: Icons.text_fields,
                        color: Colors.orangeAccent,
                        onTap: () => Get.to(() => const ReadingScreen(level: 2)),
                      ),
                      _buildLevelCard(
                        level: 'Level 3',
                        title: 'Kata',
                        icon: Icons.menu_book_outlined,
                        color: Colors.green,
                        onTap: () => Get.to(() => const ReadingScreen(level: 3)),
                      ),
                      _buildLevelCard(
                        level: 'Level 4',
                        title: 'Kalimat',
                        icon: Icons.menu_book,
                        color: Colors.blueAccent,
                        onTap: () => Get.to(() => const ReadingScreen(level: 4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required String level,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              level,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
