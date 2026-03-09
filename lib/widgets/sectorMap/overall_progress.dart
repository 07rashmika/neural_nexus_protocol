import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';

class OverallProgress extends StatelessWidget {
  const OverallProgress({
    super.key,
    required this.completed,
    required this.total,
  });
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? completed / total : 0.0;
    return PixelBorder(
      color: NeuralColors.teal,
      padding: const .symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Text(
            'Overall Progress: $completed/$total Nodes',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: NeuralColors.tealDim,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: NeuralColors.tealDark,
              valueColor: const AlwaysStoppedAnimation<Color>(
                NeuralColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
