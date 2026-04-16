//claude code
import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class SweepPainter extends CustomPainter {
  SweepPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final x = (progress * (size.width + 80)) - 40;
    final rect = Rect.fromLTWH(x - 30, 0, 60, size.height);
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        NeuralColors.teal.withValues(alpha: .18),
        Colors.transparent,
      ],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(SweepPainter old) => old.progress != progress;
}
