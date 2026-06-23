import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

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
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Image Area (Geppetto placeholder)
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.face, size: 150, color: Colors.blueGrey), // Replace with Image.asset
                  ),
                  const SizedBox(height: 40),
                  // Text Area
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Dahulu kala, hidup lah seorang pria tua bernama gepetto...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Mic and Volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 40), // Balance
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 6),
                        ),
                        child: const Icon(Icons.mic, size: 60, color: Colors.black),
                      ),
                      const TTSAudioButtons(
                        textToSpeak: "Dahulu kala, hiduplah seorang pria tua bernama gepetto...",
                        iconSize: 45.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
