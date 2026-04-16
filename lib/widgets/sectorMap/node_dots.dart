import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class NodeDots extends StatelessWidget {
  const NodeDots({
    super.key,
    required this.total,
    required this.completed,
    required this.color,
  });
  final int total;
  final int completed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: .center,
      children: List.generate(total, (i) {
        final done = i < completed;
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: .circle,
            color: done ? color : Colors.transparent,
            border: .all(
              color: done ? color : NeuralColors.tealDark,
              width: 1.5,
            ),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}