import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 12, color: NeuralColors.teal),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            color: NeuralColors.tealDim,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
