import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/drawing_element.dart';

class DrawingController extends GetxController {
  static DrawingController get to => Get.find();

  /// Reactive variables
  var elements = <DrawingElement>[].obs;
  var selectedColor = Colors.black.obs;
  var strokeWidth = 4.0.obs;
  var selectedTool = Tool.pencil.obs;
  var backgroundColor = Colors.white.obs;

  Offset? startPosition;

  /// Handle tap gesture
  void handleTap(Offset position, BuildContext context) {
    if (selectedTool.value == Tool.fill) {
      backgroundColor.value = selectedColor.value;
    } else if (selectedTool.value == Tool.text) {
      _showTextInputDialog(position, context);
    }
  }

  /// Display text input dialog
  void _showTextInputDialog(Offset position, BuildContext context) {
    TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Enter your text here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                elements.add(
                  DrawingElement(
                    position: position,
                    text: textController.text,
                    color: selectedColor.value,
                    tool: Tool.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Handle pan start gesture
  void handlePanStart(Offset position) {
    if (selectedTool.value == Tool.fill ||
        selectedTool.value == Tool.text ||
        selectedTool.value == Tool.spray) {
      startPosition = null;
    } else {
      startPosition = position;
    }
  }

  /// Handle pan update gesture
  void handlePanUpdate(Offset position) {
    if (selectedTool.value == Tool.spray) {
      _addSpray(position);
    } else if (_isShapeTool(selectedTool.value)) {
      _updateShape(position);
    } else if (_isBrushTool(selectedTool.value)) {
      _addBrushStroke(position);
    } else if (_isDrawingTool(selectedTool.value)) {
      _addDrawingPoint(position);
    }
  }

  /// Handle pan end gesture
  void handlePanEnd() {
    if (_isShapeTool(selectedTool.value)) {
      startPosition = null;
    } else if (selectedTool.value == Tool.brush) {
      elements.add(DrawingElement.endOfStroke());
    }
  }

  /// Helper methods for tool checks
  bool _isShapeTool(Tool tool) {
    return [
      Tool.star,
      Tool.circle,
      Tool.line,
      Tool.arrow,
      Tool.triangle,
      Tool.square,
    ].contains(tool);
  }

  bool _isBrushTool(Tool tool) {
    return [
      Tool.solidBrush,
      Tool.dottedBrush,
      Tool.dashedBrush,
      Tool.blurredBrush,
      Tool.neonBrush,
      Tool.gradientBrush,
    ].contains(tool);
  }

  bool _isDrawingTool(Tool tool) {
    return [Tool.pencil, Tool.brush, Tool.eraser].contains(tool);
  }

  /// Add a shape
  void _addShape(Offset start, Offset end, Tool shape) {
    elements.add(
      DrawingElement.shape(
        start: start,
        end: end,
        tool: shape,
        color: selectedColor.value,
        strokeWidth: strokeWidth.value,
      ),
    );
  }

  /// Update shape for live preview
  void _updateShape(Offset position) {
    if (startPosition != null) {
      if (elements.isNotEmpty && elements.last.tool == selectedTool.value) {
        elements.removeLast();
      }
      _addShape(startPosition!, position, selectedTool.value);
    }
  }

  /// Add spray effect
  void _addSpray(Offset position) {
    final random = Random();
    const int sprayParticleCount = 30;
    const double sprayRadius = 20.0;

    for (int i = 0; i < sprayParticleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * sprayRadius;
      final offset = Offset(
        position.dx + cos(angle) * distance,
        position.dy + sin(angle) * distance,
      );
      elements.add(
        DrawingElement.line(
          position: offset,
          paint: Paint()
            ..color = selectedColor.value
            ..strokeWidth = 2.0
            ..isAntiAlias = true,
        ),
      );
    }
  }

  /// Add brush strokes
  void _addBrushStroke(Offset position) {
    if (selectedTool.value == Tool.dottedBrush) {
      _addDottedBrush(position);
    } else if (selectedTool.value == Tool.dashedBrush) {
      _addDashedBrush(position);
    } else {
      elements.add(
        DrawingElement.line(
          position: position,
          paint: _createPaint(selectedTool.value),
        ),
      );
    }
  }

  /// Add a drawing point
  void _addDrawingPoint(Offset position) {
    elements.add(
      DrawingElement.line(
        position: position,
        paint: Paint()
          ..color = selectedTool.value == Tool.eraser
              ? backgroundColor.value
              : selectedColor.value
          ..isAntiAlias = true
          ..strokeWidth =
          selectedTool.value == Tool.eraser ? 6.0 : strokeWidth.value
          ..strokeCap = StrokeCap.round,
      ),
    );
  }

  /// Add dotted brush effect
  void _addDottedBrush(Offset position) {
    elements.add(
      DrawingElement.line(
        position: position,
        paint: Paint()
          ..color = selectedColor.value
          ..strokeWidth = strokeWidth.value
          ..style = PaintingStyle.fill,
      ),
    );
  }

  /// Add dashed brush effect
  void _addDashedBrush(Offset position) {
    if (elements.isNotEmpty && elements.last.tool == selectedTool.value) {
      final lastPoint = elements.last.position!;
      final distance = (position - lastPoint).distance;
      if (distance > 10) {
        elements.add(
          DrawingElement.line(
            position: position,
            paint: Paint()
              ..color = selectedColor.value
              ..strokeWidth = strokeWidth.value
              ..style = PaintingStyle.stroke,
          ),
        );
      }
    } else {
      elements.add(
        DrawingElement.line(
          position: position,
          paint: Paint()
            ..color = selectedColor.value
            ..strokeWidth = strokeWidth.value
            ..style = PaintingStyle.stroke,
        ),
      );
    }
  }

  /// Create paint based on tool
  Paint _createPaint(Tool tool) {
    switch (tool) {
      case Tool.solidBrush:
        return Paint()
          ..color = selectedColor.value
          ..strokeWidth = strokeWidth.value
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;
      case Tool.blurredBrush:
        return Paint()
          ..color = selectedColor.value
          ..strokeWidth = strokeWidth.value
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0)
          ..isAntiAlias = true;
      case Tool.neonBrush:
        return Paint()
          ..color = selectedColor.value
          ..strokeWidth = strokeWidth.value
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, 10)
          ..isAntiAlias = true;
      case Tool.gradientBrush:
        return Paint()
          ..shader = LinearGradient(
            colors: [selectedColor.value, selectedColor.value],
          ).createShader(Rect.fromLTWH(0, 0, 200, 200))
          ..strokeWidth = strokeWidth.value
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;
      default:
        return Paint()
          ..color = selectedColor.value
          ..strokeWidth = strokeWidth.value
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;
    }
  }

  /// Clear canvas
  void clearCanvas() {
    elements.clear();
    backgroundColor.value = Colors.white;
  }

  /// Select tool
  void selectTool(Tool tool) {
    selectedTool.value = tool;
    strokeWidth.value = tool == Tool.brush ? 8.0 : 2.0;
  }
}

