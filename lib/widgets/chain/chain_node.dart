import 'package:flutter/material.dart';

class ChainNode extends StatelessWidget {
  const ChainNode({
    super.key,
    required this.radius,
    required this.color,
    required this.glowOpacity,
    required this.glowColor,
  });

  final double radius;
  final Color color;
  final double glowOpacity;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: glowOpacity > 0
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: glowOpacity),
                  blurRadius: radius * 1.5,
                  spreadRadius: radius * 0.3,
                ),
                BoxShadow(
                  color: glowColor.withValues(alpha: glowOpacity * 0.4),
                  blurRadius: radius * 3,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Container(
          width: radius * 0.6,
          height: radius * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
