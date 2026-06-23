import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/landing_screen.dart';
import 'services/tts_service.dart';
import 'controllers/font_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(TTSService());
  Get.put(FontController(), permanent: true);
  runApp(const ReadLexiaApp());
}

class ReadLexiaApp extends StatelessWidget {
  const ReadLexiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();
    
    return Obx(() => GetMaterialApp(
      title: 'ReadLexia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEBE3CE),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEBE3CE)),
        fontFamily: fontController.currentFontFamily,
        textTheme: Typography.englishLike2021.apply(
          fontFamily: fontController.currentFontFamily,
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
    ));
  }
}
