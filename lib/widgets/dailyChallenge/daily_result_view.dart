import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';

class DailyResultView extends StatelessWidget {
  const DailyResultView({
    super.key,
    required this.challengePassed,
    required this.passedCount,
    required this.puzzleCount,
    required this.score,
    required this.bonusCarrots,
    required this.newTotalCompleted,
    required this.submitting,
    required this.onBackHome,
  });

  final bool challengePassed;
  final int passedCount;
  final int puzzleCount;
  final int score;
  final int bonusCarrots;
  final int newTotalCompleted;
  final bool submitting;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final color = challengePassed
        ? NeuralColors.teal
        : const Color(0xFFFF4B6E);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                challengePassed
                    ? Icons.verified_rounded
                    : Icons.cancel_outlined,
                color: color,
                size: 52,
              ),
              const SizedBox(height: 20),
              GlowText(
                text: challengePassed ? 'gauntlet cleared' : 'gauntlet failed',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              const SizedBox(height: 6),
              const GlowText(
                text: 'daily challenge',
                fontSize: 9,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 24),
              InfoRow(label: 'Puzzles', value: '$passedCount / $puzzleCount passed'),
              InfoRow(label: 'Score', value: '$score pts'),
              if (challengePassed) ...[
                InfoRow(label: 'Bonus carrots', value: '🥕 +$bonusCarrots'),
                InfoRow(
                  label: 'Total completed',
                  value: '$newTotalCompleted challenges',
                ),
              ],
              if (submitting)
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
              const SizedBox(height: 32),
              Button(text: 'Back to Home', onTap: onBackHome),
            ],
          ),
        ),
      ),
    );
  }
}
