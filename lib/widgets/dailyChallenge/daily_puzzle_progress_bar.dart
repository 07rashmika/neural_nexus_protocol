import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class DailyPuzzleProgressBar extends StatelessWidget {
  const DailyPuzzleProgressBar({
    super.key,
    required this.puzzleIndex,
    required this.puzzleCount,
    required this.answered,
    required this.answerCorrect,
  });

  final int puzzleIndex;
  final int puzzleCount;
  final bool answered;
  final bool? answerCorrect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'GAUNTLET  ·  BOSS  ·  ${puzzleIndex + 1}/$puzzleCount',
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            color: const Color(0xFFFF4B6E),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: List.generate(puzzleCount, (i) {
              Color color;
              if (i < puzzleIndex) {
                color = NeuralColors.teal;
              } else if (i == puzzleIndex) {
                color = answered
                    ? (answerCorrect == true
                          ? NeuralColors.teal
                          : const Color(0xFFFF4B6E))
                    : NeuralColors.tealDim;
              } else {
                color = NeuralColors.tealDark;
              }
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < puzzleCount - 1 ? 3 : 0),
                  color: color,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
