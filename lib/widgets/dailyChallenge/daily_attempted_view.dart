import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_back_button.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';

class DailyAttemptedView extends StatelessWidget {
  const DailyAttemptedView({
    super.key,
    required this.alreadyCompleted,
    required this.totalCompleted,
    required this.secondsUntilNext,
    required this.onBack,
  });

  final bool alreadyCompleted;
  final int totalCompleted;
  final int secondsUntilNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final h = secondsUntilNext ~/ 3600;
    final m = (secondsUntilNext % 3600) ~/ 60;
    final s = secondsUntilNext % 60;
    final countdown =
        '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';

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
                Icon(
                  alreadyCompleted
                      ? Icons.verified_rounded
                      : Icons.cancel_outlined,
                  color: alreadyCompleted
                      ? NeuralColors.teal
                      : const Color(0xFFFF4B6E),
                  size: 52,
                ),
                const SizedBox(height: 16),
                Text(
                  alreadyCompleted ? 'CHALLENGE COMPLETE' : 'CHALLENGE FAILED',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: alreadyCompleted
                        ? NeuralColors.teal
                        : const Color(0xFFFF4B6E),
                  ),
                ),
                const SizedBox(height: 24),
                InfoRow(
                  label: 'Total completed',
                  value: '$totalCompleted challenges',
                ),
                const SizedBox(height: 32),
                Text(
                  'NEXT CHALLENGE IN',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: NeuralColors.tealDim,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  countdown,
                  style: GoogleFonts.spaceMono(
                    fontSize: 28,
                    color: NeuralColors.teal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
