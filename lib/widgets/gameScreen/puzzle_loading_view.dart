import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';

class PuzzleLoadingView extends StatelessWidget {
  const PuzzleLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: NeuralColors.tealDim,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'LOADING...',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: NeuralColors.tealBorder,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class PuzzleErrorView extends StatelessWidget {
  const PuzzleErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: const Color(0xFFFF4B6E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Button(text: 'Retry', onTap: onRetry),
        ],
      ),
    );
  }
}
