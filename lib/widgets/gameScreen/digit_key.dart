import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';

class DigitKey extends StatelessWidget {
  const DigitKey({
    super.key,
    required this.digit,
    required this.isAnswered,
    required this.correctDigit,
    required this.selectedDigit,
    required this.isCorrectAnswer,
    required this.onTap,
    this.isEnabled = true,
  });

  final int digit;
  final bool isAnswered;
  final int? correctDigit;
  final int? selectedDigit;
  final bool? isCorrectAnswer;
  final VoidCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    var border = NeuralColors.tealDark;
    var background = Colors.transparent;
    var textColor = NeuralColors.textMain;

    if (isAnswered) {
      if (digit == correctDigit) {
        border = NeuralColors.teal;
        background = NeuralColors.teal.withValues(alpha: 0.12);
        textColor = NeuralColors.teal;
      } else if (digit == selectedDigit && !(isCorrectAnswer ?? true)) {
        border = const Color(0xFFFF4B6E);
        background = const Color(0xFFFF4B6E).withValues(alpha: 0.1);
        textColor = const Color(0xFFFF4B6E);
      } else {
        border = NeuralColors.tealDark.withValues(alpha: 0.4);
        textColor = NeuralColors.tealBorder;
      }
    }

    return GestureDetector(
      onTap: isEnabled && !isAnswered
          ? () async {
              await AppAudioService.instance.playSoftTap();
              onTap?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          color: background,
        ),
        child: Center(
          child: Text(
            '$digit',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
