import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class PuzzleTimerBar extends StatelessWidget {
  const PuzzleTimerBar({
    super.key,
    required this.timeLeft,
    required this.totalSeconds,
  });

  final int timeLeft;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalSeconds <= 0 ? 1 : totalSeconds;
    final fraction = (timeLeft / safeTotal).clamp(0.0, 1.0);
    final barColor = fraction > 0.5
        ? NeuralColors.teal
        : fraction > 0.25
            ? const Color(0xFFFFB347)
            : const Color(0xFFFF4B6E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TIME',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: NeuralColors.tealBorder,
                letterSpacing: 3,
              ),
            ),
            Text(
              '${timeLeft}s',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: barColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRect(
          child: Container(
            height: 3,
            width: double.infinity,
            color: NeuralColors.tealDark,
            child: AnimatedFractionallySizedBox(
              widthFactor: fraction,
              duration: const Duration(milliseconds: 800),
              curve: Curves.linear,
              alignment: Alignment.centerLeft,
              child: Container(color: barColor),
            ),
          ),
        ),
      ],
    );
  }
}