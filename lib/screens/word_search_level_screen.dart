import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shared_background.dart';
import 'word_search_screen.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';

class WordSearchLevelScreen extends StatelessWidget {
  const WordSearchLevelScreen({super.key});

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
                      textToSpeak: "Pilih level pencarian kata!",
                      iconSize: 40.0,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildLevelButton(
                  title: 'Level 1',
                  subtitle: '5 x 5',
                  color: const Color(0xFFFBE4E7),
                  onTap: () {
                    Get.to(() => WordSearchScreen(
                      gridSize: 5,
                      targetWords: const ['SAPI', 'BUKU', 'BOLA'],
                      grid: const [
                        ['S', 'B', 'O', 'L', 'A'],
                        ['A', 'U', 'X', 'Y', 'Z'],
                        ['P', 'K', 'P', 'Q', 'R'],
                        ['I', 'U', 'S', 'T', 'M'],
                        ['X', 'W', 'N', 'O', 'P'],
                      ],
                    ));
                  },
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  title: 'Level 2',
                  subtitle: '7 x 7',
                  color: const Color(0xFFE8F5E9),
                  onTap: () {
                    Get.to(() => WordSearchScreen(
                      gridSize: 7,
                      targetWords: const ['KUCING', 'AYAM', 'BEBEK'],
                      grid: const [
                        ['K', 'B', 'R', 'T', 'Y', 'U', 'B'],
                        ['O', 'U', 'P', 'A', 'S', 'D', 'E'],
                        ['G', 'B', 'C', 'H', 'J', 'K', 'B'],
                        ['Z', 'E', 'X', 'I', 'C', 'V', 'E'],
                        ['N', 'K', 'M', 'Q', 'N', 'W', 'K'],
                        ['R', 'S', 'T', 'U', 'V', 'G', 'W'],
                        ['A', 'Y', 'A', 'M', 'P', 'Q', 'A'],
                      ],
                    ));
                  },
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  title: 'Level 3',
                  subtitle: '9 x 9',
                  color: const Color(0xFFE3F2FD),
                  onTap: () {
                    Get.to(() => WordSearchScreen(
                      gridSize: 9,
                      targetWords: const ['MATAHARI', 'BULAN', 'BINTANG'],
                      grid: const [
                        ['B', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'B'],
                        ['I', 'I', 'O', 'P', 'A', 'S', 'D', 'F', 'U'],
                        ['G', 'H', 'N', 'J', 'K', 'L', 'Z', 'X', 'L'],
                        ['C', 'V', 'B', 'T', 'N', 'M', 'Q', 'W', 'A'],
                        ['E', 'R', 'T', 'Y', 'A', 'U', 'I', 'O', 'N'],
                        ['P', 'A', 'S', 'D', 'F', 'N', 'G', 'H', 'J'],
                        ['K', 'L', 'Z', 'X', 'C', 'V', 'G', 'B', 'N'],
                        ['M', 'A', 'T', 'A', 'H', 'A', 'R', 'I', 'X'],
                        ['M', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'],
                      ],
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,

                  ),
                ),
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
            const Icon(Icons.play_circle_fill, size: 40, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
