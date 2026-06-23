import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';
import '../utils/stroke_text_renderer.dart';

class WritingScreen extends StatefulWidget {
  final String content;

  const WritingScreen({super.key, this.content = 'A'});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  List<Offset?> _points = [];
  bool _isErasing = false;

  void _erasePoints(Offset position) {
    double eraserRadius = 20.0;
    for (int i = 0; i < _points.length; i++) {
      if (_points[i] != null && (_points[i]! - position).distance < eraserRadius) {
        _points[i] = null;
      }
    }
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  void _checkDrawing() {
    if (_points.isEmpty) {
      Get.snackbar('Oops!', 'Silakan tulis teks terlebih dahulu!', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    int validPointsCount = _points.where((p) => p != null).length;
    if (validPointsCount < 10) {
      Get.snackbar('Oops!', 'Coretan terlalu sedikit!', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // 1. Compute bounding box of user's drawing
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (var p in _points) {
      if (p != null) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }
    double width = maxX - minX;
    double height = maxY - minY;
    if (width < 10) width = 10;
    if (height < 10) height = 10;

    // Normalize user points to 0..1 scale
    List<Offset?> normalizedPoints = _points.map((p) {
      if (p == null) return null;
      return Offset((p.dx - minX) / width, (p.dy - minY) / height);
    }).toList();

    // 2. Get ideal polylines and compute their bounding box
    List<List<Offset>> idealPolylines = StrokeTextRenderer.getPolylines(widget.content, const Size(1000, 1000));
    if (idealPolylines.isEmpty) return;

    double iMinX = double.infinity, iMinY = double.infinity;
    double iMaxX = double.negativeInfinity, iMaxY = double.negativeInfinity;
    for (var polyline in idealPolylines) {
      for (var p in polyline) {
        if (p.dx < iMinX) iMinX = p.dx;
        if (p.dy < iMinY) iMinY = p.dy;
        if (p.dx > iMaxX) iMaxX = p.dx;
        if (p.dy > iMaxY) iMaxY = p.dy;
      }
    }
    double iWidth = iMaxX - iMinX;
    double iHeight = iMaxY - iMinY;
    if (iWidth < 1) iWidth = 1;
    if (iHeight < 1) iHeight = 1;

    // Normalize ideal polylines to 0..1 scale
    List<List<Offset>> normalizedIdealPolylines = [];
    for (var polyline in idealPolylines) {
      List<Offset> np = [];
      for (var p in polyline) {
        np.add(Offset((p.dx - iMinX) / iWidth, (p.dy - iMinY) / iHeight));
      }
      normalizedIdealPolylines.add(np);
    }

    // Helper: distance to segment
    double distanceToSegment(Offset p, Offset a, Offset b) {
      double l2 = (a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy);
      if (l2 == 0) return (p - a).distance;
      double t = ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
      t = t.clamp(0.0, 1.0);
      Offset projection = Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
      return (p - projection).distance;
    }

    // Dynamic tolerances based on text length
    int textLen = widget.content.length > 0 ? widget.content.length : 1;
    
    // 3. Strict Path Confinement
    // Base tolerance is 35% for 1 letter, scales down for more letters
    double maxDeviation = 0.35 / textLen; 
    if (maxDeviation < 0.1) maxDeviation = 0.1;

    for (var point in normalizedPoints) {
      if (point != null) {
        double minDistance = double.infinity;
        for (var polyline in normalizedIdealPolylines) {
          for (int i = 0; i < polyline.length - 1; i++) {
            double d = distanceToSegment(point, polyline[i], polyline[i+1]);
            if (d < minDistance) minDistance = d;
          }
        }
        if (minDistance > maxDeviation) {
          Get.snackbar('Coba Lagi!', 'Bentuk tulisanmu kurang tepat, ayo perbaiki lagi!', backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.TOP);
          return;
        }
      }
    }

    // 4. Positive Checkpoints per polyline
    double step = 0.1;
    double checkRadius = 0.3 / textLen;
    if (checkRadius < 0.1) checkRadius = 0.1;
    
    for (var polyline in normalizedIdealPolylines) {
      List<Offset> polylineCheckpoints = [];
      for (int i = 0; i < polyline.length - 1; i++) {
        Offset p1 = polyline[i];
        Offset p2 = polyline[i+1];
        double dist = (p2 - p1).distance;
        int numCheckpoints = (dist / step).ceil();
        for (int j = 0; j <= numCheckpoints; j++) {
          double t = numCheckpoints == 0 ? 0 : j / numCheckpoints;
          polylineCheckpoints.add(Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t));
        }
      }

      int passedForPolyline = 0;
      for (var checkpoint in polylineCheckpoints) {
        bool passed = false;
        for (var point in normalizedPoints) {
          if (point != null && (point - checkpoint).distance <= checkRadius) {
            passed = true;
            break;
          }
        }
        if (passed) passedForPolyline++;
      }

      double coverage = passedForPolyline / polylineCheckpoints.length;
      if (coverage < 0.6) {
        Get.snackbar('Coba Lagi!', 'Tulisanmu belum lengkap, ada garis yang terlewat!', backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        return;
      }
    }

    Get.snackbar(
      'Hebat!',
      'Tulisan kamu sangat bagus!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

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
                  // Top bar with Back and A badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE4E7), // Light pinkish square
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.content,
                          style: const TextStyle(
                            fontSize: 32, // Adjusted font size for longer texts
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tools Row
                  SizedBox(
                    width: 280,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 30, color: !_isErasing ? Colors.blue : Colors.grey),
                          onPressed: () => setState(() => _isErasing = false),
                          tooltip: 'Pensil',
                        ),
                        IconButton(
                          icon: Icon(Icons.cleaning_services, size: 30, color: _isErasing ? Colors.blue : Colors.grey),
                          onPressed: () => setState(() => _isErasing = true),
                          tooltip: 'Penghapus',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 30, color: Colors.red),
                          onPressed: _clearCanvas,
                          tooltip: 'Hapus Semua',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Center drawing canvas
                  Container(
                    width: 280,
                    height: 350,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white, // Ensure background is solid for visual clarity
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        setState(() {
                          if (_isErasing) {
                            _erasePoints(details.localPosition);
                          } else {
                            _points.add(details.localPosition);
                          }
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          if (_isErasing) {
                            _erasePoints(details.localPosition);
                          } else {
                            _points.add(details.localPosition);
                          }
                        });
                      },
                      onPanEnd: (details) {
                        if (!_isErasing) {
                          setState(() {
                            _points.add(null);
                          });
                        }
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(points: _points),
                        size: const Size(280, 350),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Cek Tulisan Button
                  ElevatedButton(
                    onPressed: _checkDrawing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9FA8DA),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Cek Tulisan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bottom Right Volume
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: TTSAudioButtons(
                      textToSpeak: "Tuliskan kembali kata di atas pada kanvas putih!",
                      iconSize: 45.0,
                    ),
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

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
