import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tracing_screen.dart';
import 'spelling_screen.dart';
import 'story_screen.dart';
import 'writing_screen.dart';
import 'word_search_level_screen.dart';
import 'tidy_up_level_screen.dart';
import 'spelling_level_screen.dart';
import 'reading_level_screen.dart';
import 'level_selection_screen.dart';
import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';
import 'profile_screen.dart' as import_profile;
import 'statistics_screen.dart' as import_stats;
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();

    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          child: WhiteCardContainer(
            badgeText: 'Menu',
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar with Back and Volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await auth.logoutChild();
                          Get.offAll(() => const LoginScreen());
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => const import_profile.ProfileScreen()),
                            child: Obx(() {
                              final user = auth.activeUser.value;
                              return CircleAvatar(
                                backgroundColor: const Color(0xFF9885D6),
                                backgroundImage: user?.profilePicture != null && user!.profilePicture!.isNotEmpty
                                    ? MemoryImage(base64Decode(user.profilePicture!))
                                    : null,
                                child: user?.profilePicture == null || user!.profilePicture!.isEmpty
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Get.to(() => const import_stats.StatisticsScreen()),
                            child: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.analytics, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const TTSAudioButtons(
                            textToSpeak: "Pilih permainan yang kamu inginkan!",
                            iconSize: 40.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Grid of 4 cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTracingIcon(dotted: true),
                            const SizedBox(height: 12),
                            const Text('Menebalkan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => Get.to(() => const LevelSelectionScreen(activityType: 'tracing')),
                      ),
                      _buildMenuCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTracingIcon(dotted: false),
                            const SizedBox(height: 12),
                            const Text('Menulis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => Get.to(() => const LevelSelectionScreen(activityType: 'writing')), 
                      ),
                      _buildMenuCard(
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.set_meal, size: 50, color: Colors.blueGrey),
                            SizedBox(height: 12),
                            Text('Mengeja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => Get.to(() => const SpellingLevelScreen()),
                      ),
                      _buildMenuCard(
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_on, size: 50, color: Colors.black87),
                            SizedBox(height: 12),
                            Text('Cari Kata', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => Get.to(() => const WordSearchLevelScreen()),
                      ),
                      _buildMenuCard(
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2, size: 50, color: Colors.brown),
                            SizedBox(height: 12),
                            Text('Beres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => Get.to(() => const TidyUpLevelScreen()),
                      ),
                      _buildMenuCard(
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 50, color: Colors.blueAccent),
                            SizedBox(height: 12),
                            Text('Membaca', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => Get.to(() => const ReadingLevelScreen()),
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

  Widget _buildMenuCard({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildTracingIcon({required bool dotted}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'A',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w900,
            color: dotted ? Colors.grey[350] : Colors.black,
            // Simulating dotted with light grey
          ),
        ),
        Positioned(
          right: -5,
          bottom: 5,
          child: Transform.rotate(
            angle: -0.5,
            child: const Icon(Icons.edit, size: 24, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
