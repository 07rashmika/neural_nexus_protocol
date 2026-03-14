import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';

class NodeProgressBar extends StatelessWidget {
  const NodeProgressBar({
    super.key,
    required this.node,
    required this.puzzleIndex,
    required this.answered,
    required this.answerCorrect,
  });

  final NodeModel node;
  final int puzzleIndex;
  final bool answered;
  final bool? answerCorrect;

  @override
  Widget build(BuildContext context) {
    final total = node.puzzleCount;
    final diffColor = difficultyColor(node.difficulty);
    return Row(
      children: [
        Text(
          'NODE ${node.nodeNumber}  ·  ${node.difficultyLabel.toUpperCase()}  ·  ${puzzleIndex + 1}/$total',
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            color: diffColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: List.generate(total, (i) {
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
                  margin: EdgeInsets.only(right: i < total - 1 ? 3 : 0),
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

Color difficultyColor(NodeDifficulty difficulty) => switch (difficulty) {
  NodeDifficulty.standard => Colors.greenAccent,
  NodeDifficulty.secured => NeuralColors.teal,
  NodeDifficulty.critical => const Color(0xFFFFB347),
  NodeDifficulty.boss => const Color(0xFFFF4B6E),
};
