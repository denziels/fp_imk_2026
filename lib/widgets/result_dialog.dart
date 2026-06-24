import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/main_menu_screen.dart';
import '../services/tts_service.dart';
import '../controllers/stats_controller.dart';
import '../controllers/progress_controller.dart';

void showResultDialog({
  required bool isCorrect,
  VoidCallback? onHome,
  VoidCallback? onReplay,
  VoidCallback? onNext,
  bool autoSpeak = true,
  String? gameId,
  String? gameName,
  int? level,
}) {
  if (gameId != null && gameName != null && level != null) {
    try {
      final stats = Get.find<StatsController>();
      stats.recordGameResult(
        gameId: gameId,
        gameName: gameName,
        level: level,
        isSuccess: isCorrect,
        details: isCorrect ? 'Berhasil menyelesaikan level' : 'Belum berhasil',
      );

      if (isCorrect) {
        Get.find<ProgressController>().completeLevel(gameId, level);
      }
    } catch (e) {
      debugPrint("Stats recording failed: $e");
    }
  }

  if (autoSpeak) {
    if (isCorrect) {
      Get.find<TTSService>().autoSpeak("Kamu hebat");
    } else {
      Get.find<TTSService>().autoSpeak("ayo belajar lagi");
    }
  }

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      backgroundColor: Colors.transparent,
      child: ResultDialogWidget(
        isCorrect: isCorrect,
        onHome: onHome ?? () => Get.offAll(() => const MainMenuScreen()),
        onReplay: onReplay,
        onNext: onNext,
      ),
    ),
    barrierDismissible: false,
  );
}

class ResultDialogWidget extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onHome;
  final VoidCallback? onReplay;
  final VoidCallback? onNext;

  const ResultDialogWidget({
    Key? key,
    required this.isCorrect,
    required this.onHome,
    this.onReplay,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Check / Cross
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                width: 5,
              ),
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.greenAccent : Colors.redAccent,
              size: 80,
            ),
          ),
          const SizedBox(height: 20),
          
          // Image
          Image.asset(
            isCorrect ? 'assets/images/benar.jpeg' : 'assets/images/salah.jpeg',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          
          const SizedBox(height: 16),
          
          // Text Feedback
          Text(
            isCorrect ? "Kamu Hebat!" : "Ayo Belajar Lagi!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.redAccent,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Home Button
              _buildIconButton(
                icon: Icons.home,
                onTap: onHome,
              ),
              const SizedBox(width: 20),
              
              // Play/Next Button (only if correct)
              if (isCorrect) ...[
                _buildIconButton(
                  icon: Icons.play_arrow,
                  onTap: () {
                    if (onNext != null) {
                      onNext!();
                    } else {
                      Get.close(2); // Close dialog and game screen
                    }
                  },
                ),
                const SizedBox(width: 20),
              ],
              
              // Replay/Refresh Button
              _buildIconButton(
                icon: Icons.refresh,
                onTap: () {
                  if (onReplay != null) {
                    onReplay!();
                  } else {
                    Get.back(); // Default action: close dialog to try again
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 40,
          color: Colors.black,
        ),
      ),
    );
  }
}
