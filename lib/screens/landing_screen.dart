import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'main_menu_screen.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors based on the image
    const Color bgColor = Color(0xFFE8DECA); // Slightly darker beige
    const Color purpleColor = Color(0xFF9885D6); // Slightly darker pastel purple
    const Color pinkColor = Color(0xFFF7A5C2); // Pastel pink

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Purple Circles (with slight drop shadows)
          _buildCircle(size: 250, top: -80, left: -80),
          _buildCircle(size: 150, top: -50, right: 100),
          _buildCircle(size: 400, top: -100, right: -150),
          _buildCircle(size: 60, top: 350, left: 30),
          _buildCircle(size: 120, top: 450, right: 30),
          _buildCircle(size: 500, bottom: -150, left: -200),
          _buildCircle(size: 250, bottom: -100, right: -50),

          // Pink Numbers
          _buildFloatingText('1', top: 60, left: 240, angle: -0.2, color: pinkColor, fontSize: 80),
          _buildFloatingText('2', top: 200, right: 160, angle: -0.15, color: pinkColor, fontSize: 90),
          _buildFloatingText('3', top: 260, right: 60, angle: 0.25, color: pinkColor, fontSize: 90),
          
          // Pink Letters
          _buildFloatingText('A', bottom: 300, left: 40, angle: -0.4, color: pinkColor, fontSize: 100),
          _buildFloatingText('B', bottom: 200, left: 140, angle: -0.25, color: pinkColor, fontSize: 100),
          _buildFloatingText('C', bottom: 60, left: 200, angle: 0.1, color: pinkColor, fontSize: 100),

          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  // ReadLexia Title with sharp solid shadow
                  Stack(
                    children: [
                      // Black Outline / Solid Shadow
                      Text(
                        'ReadLexia',
                        style: TextStyle(
 // Fallback to a playful font
                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 10
                            ..color = Colors.black,
                        ),
                      ),
                      // Solid Drop Shadow
                      const Text(
                        'ReadLexia',
                        style: TextStyle(

                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.transparent,
                          shadows: [
                            Shadow(
                              offset: Offset(5, 5),
                              blurRadius: 0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      // Inner Color
                      const Text(
                        'ReadLexia',
                        style: TextStyle(

                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: purpleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Play Button
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const MainMenuScreen());
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: pinkColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(3, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ayo mulai permainan!",
                    style: TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Right Volume Icon and Top Left Parental Guide
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Parental Guide Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: () {
                      _showParentalGuideDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Orang Tua',
                            style: TextStyle(

                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Volume Icon
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: TTSAudioButtons(
                    textToSpeak: "Ayo mulai permainan!",
                    iconSize: 45.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle({required double size, double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF9885D6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingText(String text, {double? top, double? bottom, double? left, double? right, required double angle, required Color color, required double fontSize}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,

            color: color,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(4, 4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParentalGuideDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Panduan Orang Tua',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGuideSection(
                        title: 'Apa itu Disleksia?',
                        content:
                            'Disleksia adalah salah satu jenis Kesulitan Belajar Spesifik (SpLD) yang memengaruhi perkembangan keterampilan literasi dan bahasa. Kesulitan ini tidak berkaitan dengan tingkat kecerdasan anak, melainkan disebabkan oleh perbedaan cara otak memproses informasi.',
                      ),
                      const SizedBox(height: 16),
                      _buildGuideSection(
                        title: 'Karakteristik / Ciri-ciri',
                        content:
                            '• Membaca: Anak mungkin kesulitan membaca dengan lancar dan akurat, sering salah membaca kata, atau tidak nyaman saat diminta membaca keras.\n'
                            '• Menulis: Kesulitan menyalin tulisan dari papan tulis, tulisan tangan kurang jelas, atau bermasalah dengan struktur kalimat dan ejaan kata.\n'
                            '• Pendengaran & Ingatan: Anak mungkin kesulitan mengingat instruksi, memahami fonem bahasa, serta cenderung merespons lebih lambat.',
                      ),
                      const SizedBox(height: 16),
                      _buildGuideSection(
                        title: 'Cara Menangani (Saran untuk Orang Tua & Guru)',
                        content:
                            '1. Multisensori: Gunakan pendekatan belajar yang melibatkan banyak indera (melihat, mendengar, menyentuh), seperti membuat huruf menjadi bentuk fisik, atau menggambar pemahaman mereka.\n\n'
                            '2. Penilaian Formatif & Positif: Fokus pada proses dan dukungan, bukan mengoreksi setiap kesalahan. Berikan pujian untuk membangun rasa percaya diri mereka.\n\n'
                            '3. Langkah Kecil (Chunking): Pecah informasi baru menjadi bagian-bagian kecil yang mudah dikelola agar anak tidak merasa kewalahan.\n\n'
                            '4. Lingkungan Inklusif: Pastikan materi bacaan menggunakan font yang jelas tanpa sirip (seperti Arial, bukan Times New Roman) dengan jarak spasi yang baik.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9885D6), // Purple color
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
