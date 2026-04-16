import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/node_progress_bar.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';

class NodeResultPanel extends StatelessWidget {
  const NodeResultPanel({
    super.key,
    required this.node,
    required this.passed,
    required this.passedCount,
    required this.score,
    required this.agent,
    required this.carrotsRemaining,
    required this.completing,
    required this.levelUp,
    required this.onBackSuccess,
    required this.onTryAgain,
  });

  final NodeModel node;
  final bool passed;
  final int passedCount;
  final int score;
  final Agent? agent;
  final int carrotsRemaining;
  final bool completing;
  final bool levelUp;
  final VoidCallback onBackSuccess;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final color = passed ? NeuralColors.teal : const Color(0xFFFF4B6E);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.verified_rounded : Icons.cancel_outlined,
              color: color,
              size: 52,
            ),
            const SizedBox(height: 20),
            GlowText(
              text: passed
                  ? 'NODE ${node.nodeNumber} CLEARED'
                  : 'NODE ${node.nodeNumber} FAILED',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
            const SizedBox(height: 6),
            Text(
              node.difficultyLabel.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: difficultyColor(node.difficulty),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            InfoRow(
              label: 'Puzzles',
              value: '$passedCount / ${node.puzzleCount} passed',
            ),
            InfoRow(label: 'Score', value: '$score pts'),
            if (agent != null)
              InfoRow(
                label: 'Intel',
                value: '${agent!.intelPoints.toStringAsFixed(0)} IP',
              ),
            if (agent != null)
              InfoRow(label: 'Chain', value: 'x${agent!.chainMultiplier}'),
            InfoRow(label: 'Hints left', value: '🥕 x$carrotsRemaining'),
            if (passed && completing)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Saving...',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: NeuralColors.tealDim,
                  ),
                ),
              ),
            if (levelUp)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '▲ LEVEL UP!',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: const Color(0xFFFFB347),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            if (passed)
              Button(text: 'Back to Nodes', onTap: onBackSuccess)
            else ...[
              Button(text: 'Try Again', onTap: onTryAgain),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onBackSuccess,
                child: Text(
                  'Back',
                  style: GoogleFonts.spaceMono(
                    fontSize: 15,
                    color: NeuralColors.tealDim,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
