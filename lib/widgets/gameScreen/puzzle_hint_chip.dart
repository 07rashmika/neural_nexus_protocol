import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';

class PuzzleHintChip extends StatelessWidget {
  const PuzzleHintChip({
    super.key,
    required this.label,
    required this.isAvailable,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isAvailable;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isAvailable
        ? const Color(0xFFFFB347)
        : NeuralColors.tealDark;
    final backgroundColor = isAvailable
        ? const Color(0xFFFFB347).withValues(alpha: 0.08)
        : Colors.transparent;
    final textColor = isAvailable
        ? const Color(0xFFFFB347)
        : NeuralColors.tealDark;

    return GestureDetector(
      onTap: isAvailable && !isLoading
          ? () async {
              await AppAudioService.instance.playButtonTap();
              onTap?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          color: backgroundColor,
        ),
        child: isLoading
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFFFFB347),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  letterSpacing: 1,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
