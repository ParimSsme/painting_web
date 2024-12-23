import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../data/models/drawing_element.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingElement> elements;
  final Color backgroundColor;

  DrawingPainter({
    required this.elements,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    for (final element in elements) {
      if (element.tool == Tool.pencil && element.paint != null) {
        canvas.drawCircle(
          element.position!,
          element.paint!.strokeWidth / 2,
          element.paint!,
        );
      }
      if (element.tool == Tool.dottedBrush) {
        _drawDottedBrush(canvas, element);
      } else if (element.tool == Tool.dashedBrush) {
        _drawDashedBrush(canvas, element);
      } else if (element.tool == Tool.solidBrush ||
          element.tool == Tool.blurredBrush ||
          element.tool == Tool.neonBrush ||
          element.tool == Tool.gradientBrush) {
        _drawSolidBrush(canvas, element);
      } else if (element.tool == Tool.text && element.text != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text,
            style: TextStyle(color: element.color, fontSize: 24),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, element.position!);
      } else if (element.position != null && element.paint != null) {
        canvas.drawCircle(
          element.position!,
          element.paint!.strokeWidth / 2,
          element.paint!,
        );
      } else if (element.start != null && element.end != null) {
        _drawShape(canvas, element.start!, element.end!, element.tool!,
            element.paint!);
      }
    }
  }

  void _drawSolidBrush(Canvas canvas, DrawingElement element) {
    if (element.paint != null && element.position != null) {
      canvas.drawCircle(
        element.position!,
        element.paint!.strokeWidth / 2,
        element.paint!,
      );
    }
  }

  void _drawDottedBrush(Canvas canvas, DrawingElement element) {
    if (element.paint != null && element.position != null) {
      canvas.drawCircle(
        element.position!,
        element.paint!.strokeWidth / 2,
        element.paint!,
      );
    }
  }

  void _drawDashedBrush(Canvas canvas, DrawingElement element) {
    if (element.paint != null && element.position != null) {
      // Draw individual dash as a circle
      canvas.drawCircle(
        element.position!,
        element.paint!.strokeWidth / 2,
        element.paint!,
      );
    }
  }

  void _drawShape(
      Canvas canvas, Offset start, Offset end, Tool tool, Paint paint) {
    switch (tool) {
      case Tool.line:
        canvas.drawLine(start, end, paint);
        break;
      case Tool.circle:
        final rect = Rect.fromPoints(start, end);
        canvas.drawOval(rect, paint);
        break;
      case Tool.square:
        final rect = Rect.fromPoints(start, end);
        canvas.drawRect(rect, paint);
        break;
      case Tool.triangle:
        final path = Path()
          ..moveTo((start.dx + end.dx) / 2, start.dy)
          ..lineTo(start.dx, end.dy)
          ..lineTo(end.dx, end.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case Tool.arrow:
        canvas.drawLine(start, end, paint);
        final angle = atan2(end.dy - start.dy, end.dx - start.dx);
        final arrowLength = 10.0;
        final arrow1 = Offset(
          end.dx - arrowLength * cos(angle - pi / 6),
          end.dy - arrowLength * sin(angle - pi / 6),
        );
        final arrow2 = Offset(
          end.dx - arrowLength * cos(angle + pi / 6),
          end.dy - arrowLength * sin(angle + pi / 6),
        );
        canvas.drawLine(end, arrow1, paint);
        canvas.drawLine(end, arrow2, paint);
        break;
      case Tool.star:
        final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        final radius = (end - start).distance / 2;
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final angle = i * pi / 5;
          final r = i.isEven ? radius : radius / 2;
          final x = center.dx + r * cos(angle);
          final y = center.dy + r * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}