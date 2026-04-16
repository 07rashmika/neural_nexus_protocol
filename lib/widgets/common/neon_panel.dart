import 'package:flutter/material.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class NeonPanel extends StatelessWidget {
  const NeonPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderColor = NeuralColors.tealDark,
    this.backgroundColor,
    this.width,
    this.height,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: backgroundColor ?? NeuralColors.teal.withValues(alpha: 0.02),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}