import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FontController extends GetxController {
  // 0: Normal (System), 1: Comic Sans MS, 2: OpenDyslexic
  final _fontIndex = 0.obs;

  List<String?> get fonts => [null, 'Comic Sans MS', 'OpenDyslexic'];

  String? get currentFontFamily => fonts[_fontIndex.value];

  String get currentFontName {
    if (_fontIndex.value == 0) return "Normal";
    if (_fontIndex.value == 1) return "Comic Sans";
    return "OpenDyslexic";
  }

  void toggleFont() {
    _fontIndex.value = (_fontIndex.value + 1) % 3;
    _updateTheme();
  }

  void _updateTheme() {
    // Kita panggil Get.changeTheme untuk memperbarui tema secara global
    Get.changeTheme(
      ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEBE3CE),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEBE3CE)),
        fontFamily: currentFontFamily,
        textTheme: Typography.englishLike2021.apply(
          fontFamily: currentFontFamily,
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        useMaterial3: true,
      ),
    );
  }
}
