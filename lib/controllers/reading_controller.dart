import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/tts_service.dart';

class ReadingController extends GetxController {
  final int level;

  ReadingController({required this.level});

  final stt.SpeechToText _speech = stt.SpeechToText();

  final isListening = false.obs;
  final spokenText = "".obs;
  final targetWord = "".obs;
  final isCorrect = RxnBool();
  final wordList = <String>[].obs;
  final currentIndex = 0.obs;

  bool speechEnabled = false;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    _initLevel();
  }

  Future<void> _initSpeech() async {
    speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          if (isListening.value) {
            isListening.value = false;
            if (spokenText.value.trim().isEmpty) {
              isCorrect.value = false;
              Get.find<TTSService>().autoSpeak("Suara tidak terdengar. Silakan coba lagi.");
            } else if (isCorrect.value == null) {
              submit();
            }
          }
        }
      },
      onError: (error) {
        isListening.value = false;
        Get.snackbar(
          "Error",
          error.errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  void _initLevel() {
    switch (level) {
      case 1:
        wordList.assignAll([
          "A",
          "B",
          "C",
          "D",
          "E",
        ]);
        break;

      case 2:
        wordList.assignAll([
          "Ba",
          "Bi",
          "Bu",
          "Ca",
          "Ci",
        ]);
        break;

      case 3:
        wordList.assignAll([
          "Buku",
          "Baju",
          "Bola",
          "Kaca",
          "Kuda",
        ]);
        break;

      case 4:
        wordList.assignAll([
          "Ini Budi",
          "Budi main bola",
          "Kucing tidur",
        ]);
        break;
    }

    updateTarget();
  }

  void updateTarget() {
    if (wordList.isNotEmpty) {
      targetWord.value = wordList[currentIndex.value];
    }
  }

  void nextWord() {
    if (currentIndex.value < wordList.length - 1) {
      currentIndex.value++;
      updateTarget();
      resetState();
    } else {
      Get.snackbar(
        "Selesai",
        "Semua soal telah selesai.",
      );
    }
  }

  void prevWord() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      updateTarget();
      resetState();
    }
  }

  void resetState() {
    spokenText.value = "";
    isCorrect.value = null;
    isListening.value = false;
    _speech.stop();
  }

  Future<void> listen() async {
    if (!speechEnabled) {
      await _initSpeech();
      if (!speechEnabled) {
        Get.snackbar(
          "Error",
          "Izin mikrofon ditolak atau fitur tidak tersedia",
        );
        return;
      }
    }

    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      if (spokenText.value.trim().isEmpty) {
        isCorrect.value = false;
        Get.find<TTSService>().autoSpeak("Suara tidak terdengar. Silakan coba lagi.");
      } else if (isCorrect.value == null) {
        submit();
      }
      return;
    }

    spokenText.value = "";
    isCorrect.value = null;
    isListening.value = true;

    await _speech.listen(
      localeId: "id-ID",
      partialResults: true,
      pauseFor: const Duration(seconds: 10),
      onResult: (result) {
        spokenText.value = result.recognizedWords;

        if (result.finalResult) {
          isListening.value = false;
          submit();
        }
      },
    );
  }

  void submit() {
    if (spokenText.value.trim().isEmpty) {
      isCorrect.value = false;
      Get.find<TTSService>().autoSpeak("Suara tidak terdengar. Silakan coba lagi.");
      return;
    }

    _checkAnswer(spokenText.value);
  }

  void _checkAnswer(String spoken) {
    String target = targetWord.value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();

    String result = spoken
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();

    bool match = false;

    if (level == 1) {
      final map = {
        "a": ["a", "ah"],
        "b": ["b", "be"],
        "c": ["c", "ce"],
        "d": ["d", "de"],
        "e": ["e", "eh"],
      };

      final allowed = map[target] ?? [target];

      for (final item in allowed) {
        if (result == item || result.split(" ").contains(item)) {
          match = true;
          break;
        }
      }
    } else {
      match = result == target || result.contains(target);
    }

    isCorrect.value = match;
    
    if (match) {
      Get.find<TTSService>().autoSpeak("Benar! Bagus sekali.");
    } else {
      Get.find<TTSService>().autoSpeak("Salah! Coba baca lagi kata ini.");
    }
  }

  @override
  void onClose() {
    _speech.stop();
    super.onClose();
  }
}
