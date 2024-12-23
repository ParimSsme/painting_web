import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9909618, size.height * 0.01844159);
    path_0.cubicTo(size.width * 0.9909618, size.height * 0.008256599,
        size.width * 1.081350, 0, size.width * 1.192850, 0);
    path_0.cubicTo(
        size.width * 1.304349,
        0,
        size.width * 1.394737,
        size.height * 0.008256599,
        size.width * 1.394737,
        size.height * 0.01844159);
    path_0.lineTo(size.width * 1.394737, size.height * 0.9959820);
    path_0.cubicTo(
        size.width * 1.394737,
        size.height * 1.006166,
        size.width * 1.304349,
        size.height * 1.014423,
        size.width * 1.192850,
        size.height * 1.014423);
    path_0.cubicTo(
        size.width * 1.081350,
        size.height * 1.014423,
        size.width * 0.9909618,
        size.height * 1.006166,
        size.width * 0.9909618,
        size.height * 0.9959820);
    path_0.lineTo(size.width * 0.9909618, size.height * 0.6239507);
    path_0.cubicTo(
        size.width * 0.9909618,
        size.height * 0.6072188,
        size.width * 0.9042803,
        size.height * 0.5914748,
        size.width * 0.7572368,
        size.height * 0.5814976);
    path_0.lineTo(size.width * 0.3389882, size.height * 0.5531178);
    path_0.cubicTo(
        size.width * 0.1919447,
        size.height * 0.5431406,
        size.width * 0.1052632,
        size.height * 0.5273966,
        size.width * 0.1052632,
        size.height * 0.5106647);
    path_0.lineTo(size.width * 0.1052632, size.height * 0.1564026);
    path_0.cubicTo(
        size.width * 0.1052632,
        size.height * 0.1396707,
        size.width * 0.1919447,
        size.height * 0.1239267,
        size.width * 0.3389882,
        size.height * 0.1139490);
    path_0.lineTo(size.width * 0.7859632, size.height * 0.08362103);
    path_0.cubicTo(
        size.width * 0.9149342,
        size.height * 0.07487019,
        size.width * 0.9909618,
        size.height * 0.06106034,
        size.width * 0.9909618,
        size.height * 0.04638486);
    path_0.lineTo(size.width * 0.9909618, size.height * 0.01844159);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff383A57);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void main() {
  runApp(const PaintingApp());
}

class PaintingApp extends StatelessWidget {
  const PaintingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DrawingScreen(),
    );
  }
}

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
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingElement> elements = [];
  Offset? startPosition;
  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  Tool selectedTool = Tool.brush;
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
    } else if (selectedTool == Tool.brush || selectedTool == Tool.pencil || selectedTool == Tool.eraser) {
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

  void _addDrawingPoint(Offset position) {
    setState(() {
      elements.add(DrawingElement.line(
        position: position,
        paint: Paint()
          ..color = selectedTool == Tool.eraser
              ? backgroundColor // Use background color for eraser
              : selectedColor
          ..isAntiAlias = true
          ..strokeWidth =  selectedTool == Tool.eraser ? 6 : strokeWidth
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
      appBar: AppBar(
        title: const Text('Drawing App'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                elements.clear();
                backgroundColor = Colors.white;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xff9295c5)),
                  child: CustomPaint(
                    size: Size(70, double.infinity),
                    painter: RPSCustomPainter(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 110.0, left: 5),
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
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xff9295c5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tools'),
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
        backgroundColor: selectedTool == tool ? Colors.white : Colors.white70,),
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

  factory DrawingElement.line({required Offset position, required Paint paint}) {
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

class DrawingPainter extends CustomPainter {
  final List<DrawingElement> elements;
  final Color backgroundColor;

  DrawingPainter({required this.elements, required this.backgroundColor,});

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
      } else if (element.tool == Tool.text && element.text != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text,
            style: TextStyle(color: element.color, fontSize: 24),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, element.position!);
      } else
      if (element.position != null && element.paint != null) {
        canvas.drawCircle(
          element.position!,
          element.paint!.strokeWidth / 2,
          element.paint!,
        );
      } else if (element.start != null && element.end != null) {
        _drawShape(canvas, element.start!, element.end!, element.tool!, element.paint!);
      }
    }
  }

  void _drawShape(Canvas canvas, Offset start, Offset end, Tool tool, Paint paint) {
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


