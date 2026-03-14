import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class DailyBackButton extends StatelessWidget {
  const DailyBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back_ios,
            color: NeuralColors.tealDim,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'BACK',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: NeuralColors.tealDim,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
