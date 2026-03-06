import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';

class LogoBox extends StatelessWidget {
  const LogoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelBorder(
      glow: true,
      child: Text(
        'NEURAL NEXUS\nPROTOCOL',
        textAlign: .center,
        style: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: .w700,
          color: NeuralColors.teal,
          letterSpacing: 3,
          height: 1.4,
          shadows: [
            Shadow(
              color: NeuralColors.teal.withValues(alpha: 0.9),
              blurRadius: 14,
            ),
            Shadow(
              color: NeuralColors.teal.withValues(alpha: 0.5),
              blurRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
