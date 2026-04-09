import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_back_button.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';

class DailyLobbyView extends StatelessWidget {
  const DailyLobbyView({
    super.key,
    required this.totalCompleted,
    required this.onBack,
    required this.onBegin,
  });

  final int totalCompleted;
  final VoidCallback onBack;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailyBackButton(onTap: onBack),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAILY',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: NeuralColors.tealDim,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CHALLENGE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 22,
                    color: NeuralColors.teal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                InfoRow(
                  label: 'Completed',
                  value: '$totalCompleted challenges',
                ),
                const InfoRow(
                  label: 'Format',
                  value: '5 puzzles · 12s each · no lives',
                ),
                const InfoRow(label: 'Reward', value: '🥕 +10 on completion'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFF4B6E).withValues(alpha: 0.4),
                    ),
                    color: const Color(0xFFFF4B6E).withValues(alpha: 0.04),
                  ),
                  child: Text(
                    '⚠  ALL 5 MUST PASS  ·  NO SECOND ATTEMPT TODAY',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      color: const Color(0xFFFF4B6E),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Button(text: 'Begin', onTap: onBegin),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
