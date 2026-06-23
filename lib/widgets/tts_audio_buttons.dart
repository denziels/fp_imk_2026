import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/tts_service.dart';

class TTSAudioButtons extends StatefulWidget {
  final String textToSpeak;
  final double iconSize;
  final Color activeColor;

  const TTSAudioButtons({
    super.key,
    required this.textToSpeak,
    this.iconSize = 40.0,
    this.activeColor = Colors.black,
  });

  @override
  State<TTSAudioButtons> createState() => _TTSAudioButtonsState();
}

class _TTSAudioButtonsState extends State<TTSAudioButtons> {
  final TTSService ttsService = Get.find<TTSService>();

  @override
  void initState() {
    super.initState();
    // Memutar suara otomatis (hanya jika tidak sedang di-mute)
    // Menggunakan post frame callback agar tidak memblokir render pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ttsService.autoSpeak(widget.textToSpeak);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMuted = ttsService.isMuted.value;
      
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Speaker (Untuk mengulang suara)
          GestureDetector(
            onTap: () {
              // Tetap bisa dipaksa bunyi jika user menekan tombol ini
              // Meskipun sedang mute, jika dipencet manual maka akan bunyi
              ttsService.speak(widget.textToSpeak);
            },
            child: Icon(
              Icons.volume_up,
              size: widget.iconSize,
              color: isMuted ? Colors.grey : widget.activeColor,
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Speaker Dicoret (Untuk Mute/Unmute Global)
          GestureDetector(
            onTap: () {
              ttsService.toggleMute();
            },
            child: Icon(
              Icons.volume_off,
              size: widget.iconSize - 5, // Sedikit lebih kecil agar proporsional
              color: isMuted ? Colors.red : Colors.grey[400],
            ),
          ),
        ],
      );
    });
  }
}
