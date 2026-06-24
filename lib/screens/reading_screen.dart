import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../widgets/shared_background.dart';
import '../widgets/tts_audio_buttons.dart';

class ReadingScreen extends StatelessWidget {
  final int level;
  const ReadingScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Initialize controller for this level
    final ReadingController controller = Get.put(ReadingController(level: level));

    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          child: WhiteCardContainer(
            badgeText: 'Level $level',
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
                        onTap: () {
                          Get.back();
                          Get.delete<ReadingController>();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                      const TTSAudioButtons(
                        textToSpeak: "Bacalah teks di layar dengan nyaring!",
                        iconSize: 40.0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Text Area
                  Obx(() => Container(
                    height: 200,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Text(
                      controller.targetWord.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: level == 1 ? 120 : (level == 2 ? 80 : 50),
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  )),
                  const SizedBox(height: 30),

                  // Status / Feedback
                  Obx(() {
                    if (controller.isCorrect.value == null) {
                      return Text(
                        controller.spokenText.value.isEmpty 
                          ? 'Tekan tombol mic dan baca teks di atas' 
                          : 'Mendengar: "${controller.spokenText.value}"',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  
                  const SizedBox(height: 40),
                  
                  // Mic and Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Prev Button
                      Obx(() => IconButton(
                        icon: const Icon(Icons.arrow_circle_left, size: 50, color: Colors.blueGrey),
                        onPressed: controller.currentIndex.value > 0 ? controller.prevWord : null,
                      )),
                      
                      // Mic Button
                      Obx(() => GestureDetector(
                        onTap: controller.listen,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.isListening.value ? Colors.redAccent : Colors.transparent,
                            border: Border.all(color: Colors.black, width: 6),
                            boxShadow: controller.isListening.value ? [
                              BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)
                            ] : [],
                          ),
                          child: Icon(
                            controller.isListening.value ? Icons.mic : Icons.mic_none, 
                            size: 60, 
                            color: controller.isListening.value ? Colors.white : Colors.black
                          ),
                        ),
                      )),

                      // Next Button
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right, size: 50, color: Colors.blueGrey),
                        onPressed: controller.nextWord,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Submit Button
                  Obx(() {
                    if (controller.isCorrect.value == null && !controller.isListening.value && controller.spokenText.value.isNotEmpty) {
                      return ElevatedButton(
                        onPressed: controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Koreksi / Submit', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      );
                    }
                    return const SizedBox(height: 48); // placeholder height
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
