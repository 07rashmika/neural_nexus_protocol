import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class PuzzleAnswerFeedback extends StatelessWidget {
  const PuzzleAnswerFeedback({
    super.key,
    required this.animation,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.solution,
    required this.pointsEarned,
    this.chainMultiplier,
    this.showChainBreakText = false,
    this.showCorrectAnswerOnTimeout = true,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final int? selectedAnswer;
  final int solution;
  final int pointsEarned;
  final int? chainMultiplier;
  final bool showChainBreakText;
  final bool showCorrectAnswerOnTimeout;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? NeuralColors.teal : const Color(0xFFFF4B6E);
    final multiplier = chainMultiplier ?? 1;

    String message;
    if (isCorrect) {
      message = multiplier > 1
          ? '✓  +$pointsEarned IP  x$multiplier'
          : '✓  +$pointsEarned IP';
    } else if (selectedAnswer == null) {
      message = showCorrectAnswerOnTimeout
          ? '✗  TIME\'S UP  (ans: $solution)'
          : '✗  TIME\'S UP';
      if (showChainBreakText) {
        message = '$message  —  chain broken';
      }
    } else {
      message = '✗  WRONG  (ans: $solution)';
      if (showChainBreakText) {
        message = '$message  —  chain broken';
      }
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        return Column(
          children: [
            Text(
              message,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: color,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: animation.value * 0.8),
                    blurRadius: 12 * animation.value,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            if (isCorrect && multiplier >= 2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  multiplier >= 5 ? '🔥 MAX CHAIN x$multiplier' : '⚡ CHAIN x$multiplier',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: const Color(0xFFFFB347),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}