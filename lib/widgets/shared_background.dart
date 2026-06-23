import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/font_controller.dart';

class SharedBackground extends StatelessWidget {
  final Widget child;

  const SharedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFE8DECA);
    const Color purpleColor = Color(0xFF9885D6);
    const Color pinkColor = Color(0xFFF7A5C2);

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

          // Foreground Content
          SafeArea(child: child),

          // Font Toggle Button
          Positioned(
            bottom: 20,
            left: 20,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: null, // Avoid hero tag conflicts if multiple SharedBackgrounds exist
                backgroundColor: const Color(0xFF9885D6),
                onPressed: () {
                  if (Get.isRegistered<FontController>()) {
                    Get.find<FontController>().toggleFont();
                  }
                },
                tooltip: 'Ganti Font',
                child: const Icon(Icons.text_fields, color: Colors.white),
              ),
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
}

class WhiteCardContainer extends StatelessWidget {
  final Widget child;
  final String? badgeText;

  const WhiteCardContainer({super.key, required this.child, this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF4F5), // Very light pinkish white
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(4, 8),
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        ),
        if (badgeText != null)
          Positioned(
            top: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7A5C2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(2, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,

                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
