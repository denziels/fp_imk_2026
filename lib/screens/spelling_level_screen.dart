import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shared_background.dart';
import 'spelling_screen.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';

class SpellingLevelScreen extends StatelessWidget {
  const SpellingLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: WhiteCardContainer(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    const Text(
                      'PILIH LEVEL',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,

                      ),
                    ),
                    const TTSAudioButtons(
                      textToSpeak: "Pilih level permainan!",
                      iconSize: 40.0,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildLevelButton(
                  title: 'Level 1',
                  subtitle: 'Kata: IKAN (4 Huruf)',
                  icon: Icons.set_meal,
                  color: const Color(0xFFFBE4E7),
                  onTap: () {
                    Get.to(() => const SpellingScreen(
                      targetWord: 'IKAN',
                      imageIcon: Icons.set_meal,
                      iconColor: Colors.blueGrey,
                      availableLetters: ['N', 'K', 'I', 'A', 'U'],
                      level: 1,
                    ));
                  },
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  title: 'Level 2',
                  subtitle: 'Kata: MOBIL (5 Huruf)',
                  icon: Icons.directions_car,
                  color: const Color(0xFFE8F5E9),
                  onTap: () {
                    Get.to(() => const SpellingScreen(
                      targetWord: 'MOBIL',
                      imageIcon: Icons.directions_car,
                      iconColor: Colors.red,
                      availableLetters: ['M', 'I', 'B', 'L', 'O', 'S', 'P'],
                      level: 2,
                    ));
                  },
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  title: 'Level 3',
                  subtitle: 'Kata: PESAWAT (7 Huruf)',
                  icon: Icons.flight,
                  color: const Color(0xFFE3F2FD),
                  onTap: () {
                    Get.to(() => const SpellingScreen(
                      targetWord: 'PESAWAT',
                      imageIcon: Icons.flight,
                      iconColor: Colors.blue,
                      availableLetters: ['P', 'E', 'S', 'A', 'W', 'T', 'R', 'K', 'M'],
                      level: 3,
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 350, // Diperlebar dari 280
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 28, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, size: 40, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
