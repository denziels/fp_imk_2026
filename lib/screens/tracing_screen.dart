import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';
import '../utils/stroke_text_renderer.dart';

class TracingScreen extends StatefulWidget {
  final String content;

  const TracingScreen({super.key, this.content = 'A'});

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
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
      Get.snackbar('Oops!', 'Silakan tebalkan teks terlebih dahulu!', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Get the exact segments for validation
    List<List<Offset>> allPolylines = StrokeTextRenderer.getPolylines(widget.content, const Size(280, 350));
    
    if (allPolylines.isEmpty) return;

    // Strict Path Confinement: The user must not draw too far from any segment
    double maxDeviation = 40.0; // Forgiving thickness, but strict enough to prevent scribbles

    // Helper function to calculate distance from point p to line segment a-b
    double distanceToSegment(Offset p, Offset a, Offset b) {
      double l2 = (a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy);
      if (l2 == 0) return (p - a).distance;
      double t = ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
      t = t.clamp(0.0, 1.0);
      Offset projection = Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
      return (p - projection).distance;
    }

    // 1. Strict Path Confinement
    for (var point in _points) {
      if (point != null) {
        double minDistance = double.infinity;
        for (var polyline in allPolylines) {
          for (int i = 0; i < polyline.length - 1; i++) {
            double d = distanceToSegment(point, polyline[i], polyline[i+1]);
            if (d < minDistance) {
              minDistance = d;
            }
          }
        }
        
        if (minDistance > maxDeviation) {
          Get.snackbar(
            'Coba Lagi!',
            'Coretan kamu keluar dari jalur huruf!',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }
    }

    // 2. Positive Checkpoints: Evaluated PER POLYLINE (Stroke)
    double step = 10.0; // Checkpoint every 10 pixels
    double checkRadius = 25.0; // Radius to satisfy a checkpoint

    for (var polyline in allPolylines) {
      List<Offset> polylineCheckpoints = [];
      for (int i = 0; i < polyline.length - 1; i++) {
        Offset p1 = polyline[i];
        Offset p2 = polyline[i+1];
        double dist = (p2 - p1).distance;
        int numCheckpoints = (dist / step).ceil();
        
        for (int j = 0; j <= numCheckpoints; j++) {
          double t = numCheckpoints == 0 ? 0 : j / numCheckpoints;
          polylineCheckpoints.add(Offset(
            p1.dx + (p2.dx - p1.dx) * t,
            p1.dy + (p2.dy - p1.dy) * t,
          ));
        }
      }

      int passedForPolyline = 0;
      for (var checkpoint in polylineCheckpoints) {
        bool passed = false;
        for (var point in _points) {
          if (point != null && (point - checkpoint).distance <= checkRadius) {
            passed = true;
            break;
          }
        }
        if (passed) passedForPolyline++;
      }

      // Require at least 75% coverage for EVERY individual stroke
      double coverage = passedForPolyline / polylineCheckpoints.length;
      if (coverage < 0.75) {
        Get.snackbar(
          'Coba Lagi!',
          'Ada bagian garis yang terlewat atau belum tuntas ditebalkan!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }

    Get.snackbar(
      'Hebat!',
      'Kamu berhasil menebalkan teks dengan rapi!',
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
                          color: const Color(0xFFFBE4E7),
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
                  // Center Tracing A with Drawing Canvas
                  Container(
                    width: 280,
                    height: 350,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white, // Ensure background is solid for visual clarity
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: StrokeTextPainter(text: widget.content),
                          size: const Size(280, 350),
                        ),
                        GestureDetector(
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
                      ],
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
                      textToSpeak: "Tebalkan garis putus-putus berikut!",
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

class StrokeTextPainter extends CustomPainter {
  final String text;

  StrokeTextPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    double spacing = 15.0;
    double padding = 20.0;
    double usableWidth = size.width - (padding * 2);
    double letterWidth = (usableWidth - (text.length - 1) * spacing) / text.length;
    if (letterWidth > 200) letterWidth = 200;

    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = letterWidth * 0.25 // Dynamic thicker background
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = letterWidth * 0.05 // Dynamic dashed line
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    List<List<Offset>> polylines = StrokeTextRenderer.getPolylines(text, size);
    
    // Draw thick background lines
    for (var polyline in polylines) {
      Path path = Path()..moveTo(polyline[0].dx, polyline[0].dy);
      for (int i = 1; i < polyline.length; i++) {
        path.lineTo(polyline[i].dx, polyline[i].dy);
      }
      canvas.drawPath(path, bgPaint);
    }
    
    // Draw dashed lines
    for (var polyline in polylines) {
      for (int i = 0; i < polyline.length - 1; i++) {
        _drawDashedLine(canvas, polyline[i], polyline[i+1], dashPaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 15.0;
    const dashSpace = 15.0;
    
    double distance = (p1 - p2).distance;
    if (distance == 0) return;
    
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    
    double currentDistance = 0.0;
    while (currentDistance < distance) {
      double endDistance = currentDistance + dashWidth;
      if (endDistance > distance) endDistance = distance;
      
      Offset start = Offset(p1.dx + dx * currentDistance, p1.dy + dy * currentDistance);
      Offset end = Offset(p1.dx + dx * endDistance, p1.dy + dy * endDistance);
      
      canvas.drawLine(start, end, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
