import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class ShieldCount extends StatelessWidget {
  const ShieldCount({super.key, required this.count, this.max = 3});

  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final active = i < count;
        return Icon(
          active ? Icons.shield : Icons.shield_outlined,
          color: active ? NeuralColors.teal : NeuralColors.tealDark,
          size: 28,
        );
      }),
    );
  }
}
