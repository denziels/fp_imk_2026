import 'package:flutter/material.dart';

class StrokeTextRenderer {
  static final Map<String, List<List<Offset>>> letterDefinitions = {
    'A': [
      [const Offset(0.15, 1.0), const Offset(0.5, 0.05), const Offset(0.85, 1.0)], // inverted V
      [const Offset(0.25, 0.65), const Offset(0.75, 0.65)], // crossbar
    ],
    'B': [
      [const Offset(0.2, 0), const Offset(0.2, 1)], // spine
      [ // top loop
        const Offset(0.2, 0.0),
        const Offset(0.6, 0.0),
        const Offset(0.75, 0.05),
        const Offset(0.85, 0.15),
        const Offset(0.85, 0.35),
        const Offset(0.75, 0.45),
        const Offset(0.6, 0.5),
        const Offset(0.2, 0.5),
      ], 
      [ // bottom loop
        const Offset(0.2, 0.5),
        const Offset(0.65, 0.5),
        const Offset(0.8, 0.55),
        const Offset(0.95, 0.65),
        const Offset(0.95, 0.85),
        const Offset(0.8, 0.95),
        const Offset(0.65, 1.0),
        const Offset(0.2, 1.0),
      ], 
    ],
    'K': [
      [const Offset(0.2, 0), const Offset(0.2, 1)], // spine
      [const Offset(0.8, 0), const Offset(0.2, 0.5)], // upper leg
      [const Offset(0.2, 0.5), const Offset(0.8, 1)], // lower leg
    ],
    'U': [
      [
        const Offset(0.2, 0.0),
        const Offset(0.2, 0.7),
        const Offset(0.25, 0.85),
        const Offset(0.4, 0.95),
        const Offset(0.5, 1.0),
        const Offset(0.6, 0.95),
        const Offset(0.75, 0.85),
        const Offset(0.8, 0.7),
        const Offset(0.8, 0.0),
      ],
    ]
  };

  static List<List<Offset>> getPolylines(String text, Size size) {
    List<List<Offset>> allPolylines = [];
    if (text.isEmpty) return allPolylines;

    text = text.toUpperCase();
    
    double spacing = 15.0;
    double padding = 20.0;
    double usableWidth = size.width - (padding * 2);
    double letterWidth = (usableWidth - (text.length - 1) * spacing) / text.length;
    
    // Limit letter width so it doesn't get too stretched
    if (letterWidth > 200) letterWidth = 200;
    
    // Total width used
    double totalWidth = (letterWidth * text.length) + (spacing * (text.length - 1));
    double startX = (size.width - totalWidth) / 2;
    
    double letterHeight = letterWidth * 1.5;
    if (letterHeight > size.height - 40) {
      letterHeight = size.height - 40;
      letterWidth = letterHeight / 1.5;
      totalWidth = (letterWidth * text.length) + (spacing * (text.length - 1));
      startX = (size.width - totalWidth) / 2;
    }
    
    double startY = (size.height - letterHeight) / 2;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (letterDefinitions.containsKey(char)) {
        double charStartX = startX + (i * (letterWidth + spacing));
        for (var polyline in letterDefinitions[char]!) {
          List<Offset> mappedPolyline = [];
          for (var point in polyline) {
            mappedPolyline.add(Offset(
              charStartX + (point.dx * letterWidth), 
              startY + (point.dy * letterHeight)
            ));
          }
          allPolylines.add(mappedPolyline);
        }
      }
    }
    return allPolylines;
  }
}
