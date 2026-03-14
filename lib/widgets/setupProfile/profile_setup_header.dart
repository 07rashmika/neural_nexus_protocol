import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';

class ProfileSetupHeader extends StatelessWidget {
  const ProfileSetupHeader({super.key, required this.flicker});

  final Animation<double> flicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: flicker,
            builder: (_, _) => Opacity(
              opacity: flicker.value,
              child: GlowText(
                text: 'set your agent profile'.toUpperCase(),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Configure your neural identity',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: NeuralColors.tealDim,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
