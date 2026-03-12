import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class NoShieldsDialog extends ConsumerWidget {
  const NoShieldsDialog({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shields = ref.watch(shieldProvider);
    final regenReady = shields.secondsUntilNext <= 0 && !shields.isFull;
    final minutes = (shields.secondsUntilNext ~/ 60).toString().padLeft(2, '0');
    final seconds = (shields.secondsUntilNext % 60).toString().padLeft(2, '0');

    return Dialog(
      backgroundColor: NeuralColors.bg2,
      shape: const RoundedRectangleBorder(borderRadius: .zero),
      child: Container(
        padding: const .all(32),
        decoration: BoxDecoration(border: .all(color: const Color(0xFFFF4B6E))),
        child: Column(
          mainAxisSize: .min,
          children: [
            ShieldCount(count: 0, max: ShieldState.max),
            const SizedBox(height: 24),
            Text(
              'SHIELDS DEPLETED',
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                color: const Color(0xFFFF4B6E),
                fontWeight: .w700,
                letterSpacing: 4,
              ),
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            if (regenReady) ...[
              Text(
                'Shield recharged!\nReturn to base to continue.',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: NeuralColors.teal,
                  letterSpacing: 1,
                ),
                textAlign: .center,
              ),
            ] else ...[
              Text(
                'Next shield reloads in',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: NeuralColors.tealDim,
                  letterSpacing: 1,
                ),
                textAlign: .center,
              ),
              const SizedBox(height: 8),
              Text(
                '$minutes:$seconds',
                style: GoogleFonts.spaceMono(
                  fontSize: 28,
                  color: NeuralColors.teal,
                  fontWeight: .w700,
                ),
              ),
            ],
            const SizedBox(height: 32),
            Button(
              text: regenReady ? 'Try Again' : 'Return to Base',
              onTap: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
