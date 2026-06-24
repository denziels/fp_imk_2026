import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/landing_screen.dart';
import 'services/tts_service.dart';
import 'controllers/font_controller.dart';

import 'services/storage_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/progress_controller.dart';
import 'controllers/stats_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ProgressController(), permanent: true);
  Get.put(StatsController(), permanent: true);
  
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
