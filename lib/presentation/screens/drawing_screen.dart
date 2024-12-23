import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:painting_web/presentation/widgets/toolbar_painter.dart';
import '../../data/models/drawing_element.dart';
import '../widgets/drawing_painter.dart';
import 'dart:ui' as ui;

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {

  final titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  List<DrawingElement> elements = [];
  Offset? startPosition;
  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  Tool selectedTool = Tool.pencil;
  Color backgroundColor = Colors.white;

  void _handleTap(Offset position) {
    if (selectedTool == Tool.fill) {
      setState(() {
        backgroundColor = selectedColor; // Fill the canvas with selected color
      });
    } else if (selectedTool == Tool.text) {
      _showTextInputDialog(position);
    }
  }

  void _showTextInputDialog(Offset position) {
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
                setState(() {
                  elements.add(
                    DrawingElement(
                      position: position,
                      text: textController.text,
                      color: selectedColor,
                      tool: Tool.text,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handlePanStart(Offset position) {
    if (selectedTool == Tool.fill) {
      setState(() {
        backgroundColor = selectedColor; // Fill the canvas with selected color
      });
    } else if (selectedTool == Tool.text || selectedTool == Tool.spray) {
      // These tools don't require startPosition
      return;
    } else {
      startPosition = position;
    }
  }

  void _handlePanUpdate(Offset position) {
    if (selectedTool == Tool.spray) {
      _addSpray(position);
    } else if (_isShapeTool(selectedTool)) {
      setState(() {
        if (startPosition != null) {
          // Update last element for live preview of shapes
          if (elements.isNotEmpty && elements.last.tool == selectedTool) {
            elements.removeLast();
          }
          _addShape(startPosition!, position, selectedTool);
        }
      });
    } else if (_isBrushTool(selectedTool)) {
      setState(() {
        if (selectedTool == Tool.dottedBrush) {
          _addDottedBrush(position);
        } else if (selectedTool == Tool.dashedBrush) {
          _addDashedBrush(position);
        } else {
          elements.add(
            DrawingElement.line(
              position: position,
              paint: _createPaint(selectedTool),
            ),
          );
        }
      });
    } else if (selectedTool == Tool.brush ||
        selectedTool == Tool.pencil ||
        selectedTool == Tool.eraser) {
      _addDrawingPoint(position);
    }
  }

  void _handlePanEnd() {
    if (_isShapeTool(selectedTool)) {
      // Finalize shape on pan end
      startPosition = null;
    } else if (selectedTool == Tool.brush) {
      setState(() {
        elements.add(DrawingElement.endOfStroke());
      });
    }
  }

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

  Paint _createPaint(Tool tool) {
    switch (tool) {
      case Tool.solidBrush:
        return Paint()
          ..color = selectedColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;

      case Tool.blurredBrush:
        return Paint()
          ..color = selectedColor
          ..strokeWidth = strokeWidth
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0)
          ..isAntiAlias = true;

      case Tool.neonBrush:
        return Paint()
          ..color = selectedColor
          ..strokeWidth = strokeWidth
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, 10)
          ..isAntiAlias = true;

      case Tool.gradientBrush:
        return Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(200, 200),
            [selectedColor, selectedColor.withOpacity(0)],
          )
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

      default:
        return Paint()
          ..color = selectedColor
          ..strokeWidth = strokeWidth
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;
    }
  }

  void _addDottedBrush(Offset position) {
    elements.add(
      DrawingElement.line(
        position: position,
        paint: Paint()
          ..color = selectedColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill,
      ),
    );
  }

  void _addDashedBrush(Offset position) {
    if (elements.isNotEmpty && elements.last.tool == selectedTool) {
      final lastPoint = elements.last.position!;
      final distance = (position - lastPoint).distance;
      if (distance > 10) {
        elements.add(
          DrawingElement.line(
            position: position,
            paint: Paint()
              ..color = selectedColor
              ..strokeWidth = strokeWidth
              ..style = PaintingStyle.stroke,
          ),
        );
      }
    } else {
      elements.add(
        DrawingElement.line(
          position: position,
          paint: Paint()
            ..color = selectedColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke,
        ),
      );
    }
  }

  void _addDrawingPoint(Offset position) {
    setState(() {
      elements.add(DrawingElement.line(
        position: position,
        paint: Paint()
          ..color = selectedTool == Tool.eraser
              ? backgroundColor // Use background color for eraser
              : selectedColor
          ..isAntiAlias = true
          ..strokeWidth = selectedTool == Tool.eraser ? 6 : strokeWidth
          ..strokeCap = StrokeCap.round,
      ));
    });
  }

  void _addSpray(Offset position) {
    final random = Random();
    const int sprayParticleCount = 30;
    const double sprayRadius = 20.0;

    setState(() {
      for (int i = 0; i < sprayParticleCount; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final distance = random.nextDouble() * sprayRadius;
        final offset = Offset(
          position.dx + cos(angle) * distance,
          position.dy + sin(angle) * distance,
        );
        elements.add(DrawingElement.line(
          position: offset,
          paint: Paint()
            ..color = selectedColor
            ..strokeWidth = 2.0
            ..isAntiAlias = true,
        ));
      }
    });
  }

  void _addShape(Offset start, Offset end, Tool shape) {
    elements.add(DrawingElement.shape(
      start: start,
      end: end,
      tool: shape,
      color: selectedColor,
      strokeWidth: strokeWidth,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.deepPurple.shade200),
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 70,
                    height: 450,
                    child: CustomPaint(
                      painter: ToolbarPainter(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 90.0, bottom: 90),
                        child: Column(
                          spacing: 15,
                          children: [
                            _buildColorCircle(Color(0xff61c554)),
                            _buildColorCircle(Color(0xffed695e)),
                            _buildColorCircle(Color(0xfff4bf4f)),
                            _buildColorCircle(Color(0xff4d8bb7)),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Select Color'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: Colors.primaries.map((color) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = color;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              color: color,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(10),
                                  backgroundColor: Color(0x33000000)),
                              child: const Icon(Icons.add, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xe62c2f48)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 5),
                          child: Text('Tools', style: titleStyle,),
                        ),
                        Divider(),
                        Row(
                          children: [
                            _buildToolButton(Tool.pencil, 'pen'),
                            _buildToolButton(Tool.brush, 'pen_fancy'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.eraser, 'eraser'),
                            _buildToolButton(Tool.fill, 'fill'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.text, 'font'),
                            _buildToolButton(Tool.spray, 'spray'),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 5),
                          child: Text('Brushes', style: titleStyle,),
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.solidBrush, 'brush'),
                            _buildToolButton(Tool.dottedBrush, 'brush'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.dashedBrush, 'brush'),
                            _buildToolButton(Tool.blurredBrush, 'brush'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.neonBrush, 'brush'),
                            _buildToolButton(Tool.gradientBrush, 'brush'),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 5),
                          child: Text('Shapes', style: titleStyle,),
                        ),
                        Divider(),
                        Row(
                          children: [
                            _buildToolButton(Tool.square, 'square'),
                            _buildToolButton(Tool.circle, 'circle'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.triangle, 'triangle'),
                            _buildToolButton(Tool.line, 'line'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildToolButton(Tool.star, 'star'),
                            _buildToolButton(Tool.arrow, 'arrow'),
                          ],
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            child: const Text(
                              'Clear All',
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () {
                              setState(() {
                                elements.clear();
                                backgroundColor = Colors.white;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: (details) => _handleTap(details.localPosition),
              onPanStart: (details) => _handlePanStart(details.localPosition),
              onPanUpdate: (details) => _handlePanUpdate(details.localPosition),
              onPanEnd: (details) => _handlePanEnd(),
              child: CustomPaint(
                painter: DrawingPainter(
                  elements: elements,
                  backgroundColor: backgroundColor,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(Tool tool, String icon) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTool = tool;
          strokeWidth = tool == Tool.brush
              ? 8.0
              : 2.0; // Adjust stroke width for brush/pencil
        });
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(10),
        backgroundColor: selectedTool == tool ? Colors.white : Colors.white38,
      ),
      child: SvgPicture.asset('assets/$icon.svg'),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
      ),
    );
  }
}
