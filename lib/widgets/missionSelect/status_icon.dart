import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon({super.key, required this.node});
  final NodeModel node;

  @override
  Widget build(BuildContext context) {
    if (node.isCompleted) {
      return Icon(
        Icons.star_rounded,
        color: Colors.greenAccent.withValues(alpha: 0.9),
        size: 22,
      );
    }
    if (node.isCurrent) {
      return Icon(
        Icons.play_circle_outline_rounded,
        color: NeuralColors.teal,
        size: 22,
      );
    }
    if (node.isLocked) {
      return Icon(Icons.lock_outline, color: NeuralColors.tealDark, size: 18);
    }
    return Icon(
      Icons.radio_button_unchecked,
      color: NeuralColors.tealDim,
      size: 18,
    );
  }
}
