import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';
import '../widgets/result_dialog.dart';

class SpellingScreen extends StatefulWidget {
  final String targetWord;
  final IconData imageIcon;
  final Color iconColor;
  final List<String> availableLetters;
  final int level;

  const SpellingScreen({
    super.key,
    required this.targetWord,
    required this.imageIcon,
    required this.iconColor,
    required this.availableLetters,
    required this.level,
  });

  @override
  State<SpellingScreen> createState() => _SpellingScreenState();
}

class _SpellingScreenState extends State<SpellingScreen> {
  List<String> typedLetters = [];

  void _onKeyTap(String letter) {
    if (typedLetters.length < widget.targetWord.length) {
      setState(() {
        typedLetters.add(letter.toUpperCase());
      });
      if (typedLetters.length == widget.targetWord.length) {
        if (typedLetters.join('') == widget.targetWord) {
          showResultDialog(
            isCorrect: true,
            gameId: 'spelling',
            gameName: 'Mengeja',
            level: widget.level,
            onReplay: () {
              setState(() {
                typedLetters.clear();
              });
              Get.back(); // close dialog
            },
          );
        } else {
          showResultDialog(
            isCorrect: false,
            gameId: 'spelling',
            gameName: 'Mengeja',
            level: widget.level,
            onReplay: () {
              setState(() {
                typedLetters.clear();
              });
              Get.back(); // close dialog
            },
          );
        }
      }
    }
  }

  void _onBackspace() {
    if (typedLetters.isNotEmpty) {
      setState(() {
        typedLetters.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          child: WhiteCardContainer(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar and Image
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(right: 40), // Balance the back button
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBE4E7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              width: 150,
                              height: 100,
                              color: Colors.white,
                              child: Icon(widget.imageIcon, size: 80, color: widget.iconColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Dashed Answer Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.targetWord.length, (index) {
                          String char = index < typedLetters.length ? typedLetters[index] : '';
                          return Container(
                            width: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Text(
                                  char,
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  height: 6,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Delete Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.backspace, size: 30, color: Colors.red),
                      onPressed: _onBackspace,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Keyboard
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: widget.availableLetters.map((letter) => _buildKey(letter)).toList(),
                  ),
                  const SizedBox(height: 40),
                  // Volume Icon
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: TTSAudioButtons(
                      textToSpeak: "Eja nama benda pada gambar berikut ini!",
                      iconSize: 45.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String letter) {
    return GestureDetector(
      onTap: () => _onKeyTap(letter),
      child: Container(
        width: 70,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
