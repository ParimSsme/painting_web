import 'package:flutter/cupertino.dart';

class ToolbarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9900000, size.height * 0.9968487);
    path_0.cubicTo(
        size.width * 0.9900000,
        size.height * 0.9674370,
        size.width * 0.8942857,
        size.height * 0.9397059,
        size.width * 0.7314286,
        size.height * 0.9222689);
    path_0.lineTo(size.width * 0.2871429, size.height * 0.8743697);
    path_0.cubicTo(
        size.width * 0.1242857,
        size.height * 0.8571429,
        size.width * 0.02857143,
        size.height * 0.8292017,
        size.width * 0.02857143,
        size.height * 0.7997899);
    path_0.lineTo(size.width * 0.02857143, size.height * 0.1941176);
    path_0.cubicTo(
        size.width * 0.02857143,
        size.height * 0.1647059,
        size.width * 0.1242857,
        size.height * 0.1369748,
        size.width * 0.2871429,
        size.height * 0.1195378);
    path_0.lineTo(size.width * 0.7685714, size.height * 0.06785714);
    path_0.cubicTo(
        size.width * 0.9085714,
        size.height * 0.05294118,
        size.width * 0.9900000,
        size.height * 0.02899160,
        size.width * 0.9900000,
        size.height * 0.003781513);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff2c2f48);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}