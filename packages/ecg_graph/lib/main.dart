import 'package:flutter/material.dart';
import 'dart:math';

class ECGGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(300, 150), // 设置绘制区域的大小
      painter: ECGPainter(),
    );
  }
}

class ECGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    final double dx = size.width / 500;
    double x = 0;
    final double centerY = size.height / 2;

    for (int i = 0; i < 500; i++) {
      final double y = sin(2 * pi * i / 20) * 40; // 模拟心电图波形
      if (i == 0) {
        path.moveTo(x, centerY - y);
      } else {
        path.lineTo(x, centerY - y);
      }
      x += dx;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ECG Graph'),
        ),
        body: Center(
          child: ECGGraph(),
        ),
      ),
    ),
  );
}
