import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';

class GlowText extends StatefulWidget {
  const GlowText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.letterSpacing,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  @override
  State<GlowText> createState() => _GlowTextState();
}

class _GlowTextState extends State<GlowText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.toUpperCase(),
      textAlign: .center,
      style: GoogleFonts.spaceMono(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: NeuralColors.teal,
        letterSpacing: widget.letterSpacing,
        shadows: [
          Shadow(
            color: NeuralColors.teal.withValues(alpha: .9),
            blurRadius: 12,
          ),
          Shadow(
            color: NeuralColors.teal.withValues(alpha: .5),
            blurRadius: 28,
          ),
        ],
      ),
    );
  }
}
