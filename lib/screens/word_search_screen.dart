import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';
import '../widgets/result_dialog.dart';

class WordSearchScreen extends StatefulWidget {
  final int gridSize;
  final List<String> targetWords;
  final List<List<String>> grid;
  final int level;

  const WordSearchScreen({
    super.key,
    required this.gridSize,
    required this.targetWords,
    required this.grid,
    required this.level,
  });

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  List<String> foundWords = [];
  List<int> selectedIndices = [];
  String currentSelection = "";

  void _onTileTap(int index) {
    // If user taps an already selected tile, reset the selection
    if (selectedIndices.contains(index)) {
      setState(() {
        currentSelection = "";
        selectedIndices.clear();
      });
      return;
    }

    int row = index ~/ widget.gridSize;
    int col = index % widget.gridSize;
    String letter = widget.grid[row][col];

    setState(() {
      selectedIndices.add(index);
      currentSelection += letter;
    });

    // Check for match
    if (widget.targetWords.contains(currentSelection) && !foundWords.contains(currentSelection)) {
      setState(() {
        foundWords.add(currentSelection);
        currentSelection = "";
        selectedIndices.clear();
      });
      if (foundWords.length == widget.targetWords.length) {
        showResultDialog(
          isCorrect: true,
          gameId: 'word_search',
          gameName: 'Cari Kata',
          level: widget.level,
          onReplay: () {
            setState(() {
              foundWords.clear();
              currentSelection = "";
              selectedIndices.clear();
            });
            Get.back();
          },
        );
      }
    } else {
      // Find the maximum length among target words
      int maxLength = 0;
      for (String w in widget.targetWords) {
        if (w.length > maxLength) maxLength = w.length;
      }
      
      // Reset if selection exceeds the longest possible word
      if (currentSelection.length >= maxLength) {
        setState(() {
          currentSelection = "";
          selectedIndices.clear();
        });
      }
    }
  }

  void _resetSelection() {
    setState(() {
      currentSelection = "";
      selectedIndices.clear();
    });
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
                  // Top bar
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
                        'CARI KATA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,

                        ),
                      ),
                      const TTSAudioButtons(
                        textToSpeak: "Temukan kata-kata yang tersembunyi di dalam kotak huruf!",
                        iconSize: 40.0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Word Search Grid Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE4E7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.gridSize * widget.gridSize,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: widget.gridSize,
                              mainAxisSpacing: widget.gridSize > 5 ? 4 : 8,
                              crossAxisSpacing: widget.gridSize > 5 ? 4 : 8,
                            ),
                            itemBuilder: (context, index) {
                              int row = index ~/ widget.gridSize;
                              int col = index % widget.gridSize;
                              String letter = widget.grid[row][col];
                              bool isSelected = selectedIndices.contains(index);

                              return GestureDetector(
                                onTap: () => _onTileTap(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.yellow : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[400]!, width: isSelected ? 3 : 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        fontSize: widget.gridSize == 5 ? 24 : widget.gridSize == 7 ? 18 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.orange[800] : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Vertical Progress Bar
                      Container(
                        width: 40,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 40,
                            height: 250 * (foundWords.length / widget.targetWords.length),
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent[400],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Bottom Dashed Words
                  Wrap(
                    spacing: 15,
                    runSpacing: 25,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      widget.targetWords.length, 
                      (index) => _buildDashedWord(index)
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Selesai Button
                  if (foundWords.length == widget.targetWords.length)
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9FA8DA), // Indigo/Purple-ish
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'selesai',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashedWord(int targetIndex) {
    String word = widget.targetWords[targetIndex];
    bool isFound = foundWords.contains(word);

    return Row(
      children: List.generate(word.length, (index) {
        return Container(
          width: 35,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Text(
                isFound ? word[index] : '',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isFound ? Colors.green : Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
