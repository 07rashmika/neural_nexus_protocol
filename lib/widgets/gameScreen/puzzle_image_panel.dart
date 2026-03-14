import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/neon_panel.dart';

class PuzzleImagePanel extends StatelessWidget {
  const PuzzleImagePanel({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeonPanel(
        width: double.infinity,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: NeuralColors.tealDim,
                  ),
                ),
          errorBuilder: (_, _, _) => Center(
            child: Text(
              'IMAGE ERROR',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFFFF4B6E),
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
