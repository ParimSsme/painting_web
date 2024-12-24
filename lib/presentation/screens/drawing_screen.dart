import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/drawing_element.dart';
import '../widgets/drawing_painter.dart';
import 'package:get/get.dart';
import '../controllers/drawing_controller.dart';
import '../widgets/toolbar_painter.dart';

class DrawingScreen extends StatelessWidget {
  const DrawingScreen({super.key});

  final titleStyle = const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final controller = DrawingController.to;

    return GetX<DrawingController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: controller.backgroundColor.value,
          body: Row(
            children: [
              _buildToolPanel(controller, context),
              _buildDrawingCanvas(controller, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolPanel(DrawingController controller, BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColorSelector(controller, context),
          _buildToolCategories(controller),
        ],
      ),
    );
  }

  Widget _buildColorSelector(DrawingController controller, BuildContext context) {
    return
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
                  _buildColorCircle(controller, const Color(0xff61c554)),
                  _buildColorCircle(controller, const Color(0xffed695e)),
                  _buildColorCircle(controller, const Color(0xfff4bf4f)),
                  _buildColorCircle(controller, const Color(0xff4d8bb7)),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Select Color'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: Colors.primaries.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.selectedColor.value = color;
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 50,
                                      color: color,
                                      margin: const EdgeInsets.symmetric(vertical: 2),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: Colors.white38,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildToolCategories(DrawingController controller) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Color(0xe62c2f48)),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategory('Tools', [
              _buildToolButton(controller, Tool.pencil, 'pen'),
              _buildToolButton(controller, Tool.brush, 'pen_fancy'),
              _buildToolButton(controller, Tool.eraser, 'eraser'),
              _buildToolButton(controller, Tool.fill, 'fill'),
              _buildToolButton(controller, Tool.text, 'font'),
              _buildToolButton(controller, Tool.spray, 'spray'),
            ]),
            _buildCategory('Brushes', [
              _buildToolButton(controller, Tool.solidBrush, 'brush'),
              _buildToolButton(controller, Tool.dottedBrush, 'brush'),
              _buildToolButton(controller, Tool.dashedBrush, 'brush'),
              _buildToolButton(controller, Tool.blurredBrush, 'brush'),
              _buildToolButton(controller, Tool.neonBrush, 'brush'),
              _buildToolButton(controller, Tool.gradientBrush, 'brush'),
            ]),
            _buildCategory('Shapes', [
              _buildToolButton(controller, Tool.square, 'square'),
              _buildToolButton(controller, Tool.circle, 'circle'),
              _buildToolButton(controller, Tool.triangle, 'triangle'),
              _buildToolButton(controller, Tool.line, 'line'),
              _buildToolButton(controller, Tool.star, 'star'),
              _buildToolButton(controller, Tool.arrow, 'arrow'),
            ]),

            Spacer(),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: controller.clearCanvas,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(title, style: titleStyle),
        const Divider(),
        ..._buildRows(buttons, 2),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildRows(List<Widget> items, int itemsPerRow) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += itemsPerRow) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items
              .skip(i)
              .take(itemsPerRow)
              .map((item) => item)
              .toList(),
        ),
      );
    }
    return rows;
  }

  Widget _buildToolButton(DrawingController controller, Tool tool, String icon) {
    return Obx(
          () => ElevatedButton(
        onPressed: () => controller.selectTool(tool),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(10),
          backgroundColor: controller.selectedTool.value == tool
              ? Colors.white
              : Colors.white38,
        ),
        child: SvgPicture.asset('assets/$icon.svg', width: 24, height: 24),
      ),
    );
  }

  Widget _buildColorCircle(DrawingController controller, Color color) {
    return GestureDetector(
      onTap: () => controller.selectedColor.value = color,
      child: Obx(
            () => Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: controller.selectedColor.value == color
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingCanvas(DrawingController controller, BuildContext context) {
    return Expanded(
      child: GestureDetector(
          onTapDown: (details) =>
                      controller.handleTap(details.localPosition, context),
                  onPanStart: (details) =>
                      controller.handlePanStart(details.localPosition),
                  onPanUpdate: (details) =>
                      controller.handlePanUpdate(details.localPosition),
                  onPanEnd: (details) => controller.handlePanEnd(),
        child: Obx(
              () => CustomPaint(
            painter: DrawingPainter(
              elements: controller.elements.value,
              backgroundColor: controller.backgroundColor.value,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

