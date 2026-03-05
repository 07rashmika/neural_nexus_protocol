import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/widgets/pixel_border.dart';

class PlayerStats extends StatelessWidget {
  const PlayerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelBorder(
      glowMax: 0,
      child: Column(
        children: [
          const Text('Agent_X'),
          Row(
            mainAxisSize: .min,
            children: [
              const Text('Agent_X'),
              const Text('|'),
              const Text('Pro'),
            ],
          ),
        ],
      ),
    );
  }
}
