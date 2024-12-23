import 'package:flutter/material.dart';

enum Tool {
  brush,
  pencil,
  fill,
  eraser,
  text,
  spray,
  star,
  circle,
  line,
  arrow,
  triangle,
  square,
  solidBrush,
  dottedBrush,
  dashedBrush,
  blurredBrush,
  neonBrush,
  gradientBrush,
}

class DrawingElement {
  final Offset? start;
  final Offset? end;
  final Offset? position;
  final String? text;
  final Color? color;
  final Paint? paint;
  final Tool? tool;

  DrawingElement({
    this.start,
    this.end,
    this.position,
    this.text,
    this.color,
    this.paint,
    this.tool,
  });

  factory DrawingElement.line(
      {required Offset position, required Paint paint}) {
    return DrawingElement(position: position, paint: paint);
  }

  factory DrawingElement.shape({
    required Offset start,
    required Offset end,
    required Tool tool,
    required Color color,
    required double strokeWidth,
  }) {
    return DrawingElement(
      start: start,
      end: end,
      tool: tool,
      paint: Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true,
    );
  }

  factory DrawingElement.endOfStroke() {
    return DrawingElement();
  }
}
