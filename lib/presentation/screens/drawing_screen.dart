import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:painting_web/presentation/widgets/toolbar_painter.dart';
import '../../data/models/drawing_element.dart';
import '../widgets/drawing_painter.dart';
import 'package:get/get.dart';
import '../controllers/drawing_controller.dart';

class DrawingScreen extends StatelessWidget {
  final titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  DrawingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<DrawingController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: controller.backgroundColor.value,
          body: Row(
            children: [
              SizedBox(
                width: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.deepPurple.shade200),
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 70,
                        height: 450,
                        child: CustomPaint(
                          painter: ToolbarPainter(),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 90.0, bottom: 90),
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
                                            children:
                                                Colors.primaries.map((color) {
                                              return GestureDetector(
                                                onTap: () {
                                                  controller
                                                      .selectedColor(color);
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
                                    backgroundColor: Colors.white38,
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.white),
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
                          spacing: 10,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 5),
                              child: Text(
                                'Tools',
                                style: titleStyle,
                              ),
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
                              child: Text(
                                'Brushes',
                                style: titleStyle,
                              ),
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
                              child: Text(
                                'Shapes',
                                style: titleStyle,
                              ),
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                onPressed: () {
                                  controller.clearCanvas();
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
                  onTapDown: (details) =>
                      controller.handleTap(details.localPosition, context),
                  onPanStart: (details) =>
                      controller.handlePanStart(details.localPosition),
                  onPanUpdate: (details) =>
                      controller.handlePanUpdate(details.localPosition),
                  onPanEnd: (details) => controller.handlePanEnd(),
                  child: CustomPaint(
                    painter: DrawingPainter(
                      elements: controller.elements.value,
                      backgroundColor: controller.backgroundColor.value,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolButton(Tool tool, String icon) {
    return Obx(
      () => ElevatedButton(
        onPressed: () {
          DrawingController.to.selectTool(tool);
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(10),
          backgroundColor: DrawingController.to.selectedTool.value == tool
              ? Colors.white
              : Colors.white38,
        ),
        child: SvgPicture.asset('assets/$icon.svg'),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        DrawingController.to.selectedColor.value = color;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: DrawingController.to.selectedColor.value == color
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
      ),
    );
  }
}
