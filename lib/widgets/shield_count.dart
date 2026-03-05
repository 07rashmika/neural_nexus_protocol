import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class ShieldCount extends StatelessWidget {
  const ShieldCount({super.key});

  @override
  Widget build(BuildContext context) {
    Icon outlinedShield = Icon(Icons.shield_outlined, color: NeuralColors.teal);
    Icon shield = Icon(Icons.shield, color: NeuralColors.teal);
    return Row(mainAxisSize: .min, children: [shield, shield, outlinedShield]);
  }
}
