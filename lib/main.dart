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

enum Tool { brush, pencil, fill, eraser, text, spray }

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingElement?> elements = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  Tool selectedTool = Tool.brush;
  Color backgroundColor = Colors.white;

  void _handleTap(Offset position) {
    if (selectedTool == Tool.text) {
      _showTextInputDialog(position);
    }
  }

  void _handlePanStart(Offset position) {
    if (selectedTool == Tool.fill) {
      setState(() {
        backgroundColor = selectedColor; // Fill the canvas with selected color
      });
    } else if (selectedTool == Tool.spray) {
      _addSpray(position);
    } else {
      _addDrawingPoint(position);
    }
  }

  void _handlePanUpdate(Offset position) {
    if (selectedTool == Tool.spray) {
      _addSpray(position);
    } else if (selectedTool != Tool.fill) {
      _addDrawingPoint(position);
    }
  }

  void _handlePanEnd() {
    if (selectedTool != Tool.spray) {
      setState(() {
        elements.add(null); // Add null to separate strokes
      });
    }
  }

  void _addDrawingPoint(Offset position) {
    setState(() {
      elements.add(
        DrawingElement(
          position: position,
          paint: Paint()
            ..color = selectedTool == Tool.eraser
                ? backgroundColor // Use background color for eraser
                : selectedColor
            ..isAntiAlias = true
            ..strokeWidth =  selectedTool == Tool.eraser ? 6 : strokeWidth
            ..strokeCap = StrokeCap.round,
          type: ElementType.line,
        ),
      );
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
        elements.add(
          DrawingElement(
            position: offset,
            paint: Paint()
              ..color = selectedColor
              ..isAntiAlias = true
              ..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round,
            type: ElementType.line,
          ),
        );
      }
    });
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
                      type: ElementType.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Advanced Drawing App'),
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

enum ElementType { line, text }

class DrawingElement {
  final Offset position;
  final Paint? paint;
  final String? text;
  final Color? color;
  final ElementType type;

  DrawingElement({
    required this.position,
    this.paint,
    this.text,
    this.color,
    required this.type,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingElement?> elements;
  final Color backgroundColor;

  DrawingPainter({required this.elements, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    for (final element in elements) {
      if (element == null) continue;

      if (element.type == ElementType.line && element.paint != null) {
        canvas.drawCircle(
          element.position,
          element.paint!.strokeWidth / 2,
          element.paint!,
        );
      } else if (element.type == ElementType.text && element.text != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text,
            style: TextStyle(color: element.color, fontSize: 24),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, element.position);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

