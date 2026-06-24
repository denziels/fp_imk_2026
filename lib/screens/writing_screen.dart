import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';
import '../widgets/result_dialog.dart';
import '../utils/stroke_text_renderer.dart';

class WritingScreen extends StatefulWidget {
  final String content;
  final int level;

  const WritingScreen({super.key, this.content = 'A', required this.level});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  List<Offset?> _points = [];
  List<List<Offset?>> _undoStack = [];
  List<List<Offset?>> _redoStack = [];
  bool _isErasing = false;

  void _undo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _redoStack.add(List.from(_points));
        _points = _undoStack.removeLast();
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _undoStack.add(List.from(_points));
        _points = _redoStack.removeLast();
      });
    }
  }

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
      _undoStack.add(List.from(_points));
      _redoStack.clear();
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

    // Normalize user points to 0..1 scale (Stretch to bounds to ignore aspect ratio/spacing variations)
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

    // Normalize ideal polylines to 0..1 scale (Stretch to bounds)
    List<List<Offset>> normalizedIdealPolylines = [];
    for (var polyline in idealPolylines) {
      List<Offset> np = [];
      for (var p in polyline) {
        np.add(Offset((p.dx - iMinX) / iWidth, (p.dy - iMinY) / iHeight));
      }
      normalizedIdealPolylines.add(np);
    }

    // Dynamic tolerances based on text length
    int textLen = widget.content.length > 0 ? widget.content.length : 1;
    
    // Hitung jumlah coretan (strokes)
    int strokeCount = 0;
    bool inStroke = false;
    for (var p in _points) {
      if (p != null) {
        if (!inStroke) {
          strokeCount++;
          inStroke = true;
        }
      } else {
        inStroke = false;
      }
    }

    // Jika kata lebih dari 1 huruf, mustahil ditulis dengan 1 coretan tanpa diangkat (mencegah trik lingkaran besar)
    if (textLen > 1 && strokeCount < 2) {
      showResultDialog(
        isCorrect: false,
        gameId: 'writing',
        gameName: 'Menulis',
        level: widget.level,
        onReplay: () {
          _clearCanvas();
          Get.back();
        },
      );
      return;
    }

    // 3. Strict Path Confinement
    // Toleransi: 25% universal
    double maxDeviation = 0.25;

    // Helper: distance to segment
    double distanceToSegment(Offset p, Offset a, Offset b) {
      double l2 = (a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy);
      if (l2 == 0) return (p - a).distance;
      double t = ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
      t = t.clamp(0.0, 1.0);
      Offset projection = Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
      return (p - projection).distance;
    }

    // Calculate total length of user's drawing in normalized space
    double userDrawingLength = 0;
    for (int i = 0; i < normalizedPoints.length - 1; i++) {
      if (normalizedPoints[i] != null && normalizedPoints[i+1] != null) {
        userDrawingLength += (normalizedPoints[i]! - normalizedPoints[i+1]!).distance;
      }
    }
    
    // Calculate total length of ideal drawing in normalized space
    double idealDrawingLength = 0;
    for (var polyline in normalizedIdealPolylines) {
      for (int i = 0; i < polyline.length - 1; i++) {
        idealDrawingLength += (polyline[i] - polyline[i+1]).distance;
      }
    }

    // Cegah coret-coret asal
    if (userDrawingLength > idealDrawingLength * 2.5) {
      showResultDialog(
        isCorrect: false,
        gameId: 'writing',
        gameName: 'Menulis',
        level: widget.level,
        onReplay: () {
          _clearCanvas();
          Get.back();
        },
      );
      return;
    }

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
          showResultDialog(
            isCorrect: false,
            gameId: 'writing',
            gameName: 'Menulis',
            level: widget.level,
            onReplay: () {
              _clearCanvas();
              Get.back();
            },
          );
          return;
        }
      }
    }

    // 4. Positive Checkpoints per polyline
    double step = 0.1;
    // Radius pengecekan: 25% universal. Cukup besar untuk menangkap garis melintang (crossbar) yang ditulis agak tinggi/rendah.
    double checkRadius = 0.25;
    
    bool allPolylinesPassed = true;
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

      double coverage = polylineCheckpoints.isEmpty ? 0 : passedForPolyline / polylineCheckpoints.length;
      double requiredCoverage = 0.45; // 45% universal.

      if (coverage < requiredCoverage) {
        allPolylinesPassed = false;
        break;
      }
    }

    if (allPolylinesPassed) {
      showResultDialog(
        isCorrect: true,
        gameId: 'writing',
        gameName: 'Menulis',
        level: widget.level,
        onReplay: () {
          _clearCanvas();
          Get.back();
        },
      );
    } else {
      showResultDialog(
        isCorrect: false,
        gameId: 'writing',
        gameName: 'Menulis',
        level: widget.level,
        onReplay: () {
          _clearCanvas();
          Get.back();
        },
      );
    }
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
                        Container(
                          decoration: !_isErasing
                              ? BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: IconButton(
                            icon: Icon(Icons.edit, size: 30, color: !_isErasing ? Colors.blue : Colors.grey),
                            onPressed: () => setState(() => _isErasing = false),
                            tooltip: 'Pensil',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: _isErasing
                              ? BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: IconButton(
                            icon: SizedBox(
                              width: 30,
                              height: 30,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 0,
                                    child: Transform.rotate(
                                      angle: 0.6,
                                      child: Container(
                                        width: 14,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: _isErasing ? Colors.blue : Colors.grey, width: 2.5),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(height: 2.5, color: _isErasing ? Colors.blue : Colors.grey),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: 26,
                                      height: 2.5,
                                      decoration: BoxDecoration(
                                        color: _isErasing ? Colors.blue : Colors.grey,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () => setState(() => _isErasing = true),
                            tooltip: 'Penghapus',
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.undo, size: 30, color: _undoStack.isNotEmpty ? Colors.blue : Colors.grey),
                          onPressed: _undoStack.isNotEmpty ? _undo : null,
                          tooltip: 'Undo',
                        ),
                        IconButton(
                          icon: Icon(Icons.redo, size: 30, color: _redoStack.isNotEmpty ? Colors.blue : Colors.grey),
                          onPressed: _redoStack.isNotEmpty ? _redo : null,
                          tooltip: 'Redo',
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
                          _undoStack.add(List.from(_points));
                          _redoStack.clear();
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
