import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class LogoBox extends StatelessWidget {
  const LogoBox({super.key, required this.glowOpacity});

  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: .all(color: NeuralColors.teal, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: NeuralColors.teal.withValues(alpha: glowOpacity),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: NeuralColors.teal.withValues(alpha: glowOpacity * .3),
            blurRadius: 50,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          ..._cornerBrackets(),
          Text(
            'NEURAL NEXUS PROTOCOL',
            textAlign: .center,
            style: GoogleFonts.spaceMono(
              fontSize: 20,
              fontWeight: .w700,
              color: NeuralColors.teal,
              letterSpacing: 3,
              height: 1.4,
              shadows: [
                Shadow(
                  color: NeuralColors.teal.withValues(alpha: .9),
                  blurRadius: 14,
                ),
                Shadow(
                  color: NeuralColors.teal.withValues(alpha: .5),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _cornerBrackets() {
  const size = 10.0;
  const thickness = 2.0;
  const color = NeuralColors.teal;
  const offset = 8.0;

  Widget bracket({
    required AlignmentGeometry alignment,
    required Border border,
  }) {
    return Positioned(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: border),
      ),
    );
  }

  return [
    bracket(
      alignment: .topLeft,
      border: const Border(
        top: BorderSide(color: color, width: thickness),
        left: BorderSide(color: color, width: thickness),
      ),
    ),
    bracket(
      alignment: .topRight,
      border: const Border(
        top: BorderSide(color: color, width: thickness),
        right: BorderSide(color: color, width: thickness),
      ),
    ),
    bracket(
      alignment: .bottomLeft,
      border: const Border(
        bottom: BorderSide(color: color, width: thickness),
        left: BorderSide(color: color, width: thickness),
      ),
    ),
    bracket(
      alignment: .bottomRight,
      border: const Border(
        bottom: BorderSide(color: color, width: thickness),
        right: BorderSide(color: color, width: thickness),
      ),
    ),
  ];
}
