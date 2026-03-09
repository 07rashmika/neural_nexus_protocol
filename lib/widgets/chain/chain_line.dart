import 'package:flutter/material.dart';

class ChainLine extends StatelessWidget {
  const ChainLine({
    super.key,
    required this.length,
    required this.thickness,
    required this.color,
    required this.glowOpacity,
    required this.glowColor,
  });

  final double length;
  final double thickness;
  final Color color;
  final double glowOpacity;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: length,
      height: thickness,
      decoration: BoxDecoration(
        color: color,
        borderRadius: .circular(thickness / 2),
        boxShadow: glowOpacity > 0
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: glowOpacity),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
    );
  }
}
