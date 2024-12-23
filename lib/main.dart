import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painting_web/presentation/controllers/drawing_controller.dart';
import 'package:painting_web/presentation/screens/drawing_screen.dart';

void main() {
  Get.put(DrawingController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  DrawingScreen(),
    );
  }
}
