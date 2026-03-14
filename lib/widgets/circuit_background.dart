import 'package:flutter/material.dart';

import '../painters/circuit_painter.dart';

class CircuitBackground extends StatefulWidget {
  const CircuitBackground({super.key});

  @override
  State<CircuitBackground> createState() => _CircuitBackgroundState();
}

class _CircuitBackgroundState extends State<CircuitBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: CircuitPainter(progress: _controller.value),
        size: Size.infinite,
      ),
    );
  }
}
