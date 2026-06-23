import 'package:get/get.dart';

class SpellingController extends GetxController {
  final String targetWord = "ikan";
  var currentSpelling = "".obs;
  var isFinished = false.obs;

  // Huruf acak untuk dipilih (berisi huruf-huruf dari "ikan" dan pengecoh)
  final List<String> availableLetters = ["n", "k", "i", "a", "u"];

  void addLetter(String letter) {
    if (isFinished.value) return;

    // Cek apakah huruf sesuai urutan target word
    int currentLength = currentSpelling.value.length;
    if (currentLength < targetWord.length) {
      String expectedLetter = targetWord[currentLength];
      if (letter == expectedLetter) {
        currentSpelling.value += letter;
        
        if (currentSpelling.value == targetWord) {
          isFinished.value = true;
        }
      }
    }
  }

  void reset() {
    currentSpelling.value = "";
    isFinished.value = false;
  }
}
