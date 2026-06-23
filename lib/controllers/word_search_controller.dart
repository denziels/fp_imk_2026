import 'package:get/get.dart';

class WordSearchController extends GetxController {
  // Grid 5x5
  final List<String> gridLetters = [
    "k", "o", "p", "i", "n",
    "x", "m", "a", "n", "a",
    "i", "k", "a", "n", "z",
    "h", "a", "t", "i", "v",
    "b", "u", "k", "u", "r",
  ];

  final List<String> targetWords = ["kopi", "mana", "ikan", "hati"];
  var foundWords = <String>[].obs;
  var isCompleted = false.obs;

  void checkWordFound(String word) {
    if (!foundWords.contains(word) && targetWords.contains(word)) {
      foundWords.add(word);
      if (foundWords.length == targetWords.length) {
        isCompleted.value = true;
      }
    }
  }

  // Simulasi jika user swipe / tap
  void simulateFindWord(String word) {
    checkWordFound(word);
  }

  void reset() {
    foundWords.clear();
    isCompleted.value = false;
  }
}
