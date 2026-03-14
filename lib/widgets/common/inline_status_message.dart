import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/neon_panel.dart';

class InlineStatusMessage extends StatelessWidget {
  const InlineStatusMessage.loading({super.key, required this.message})
    : isLoading = true,
      error = null,
      onRetry = null;

  const InlineStatusMessage.error({
    super.key,
    required this.error,
    required this.onRetry,
  }) : isLoading = false,
       message = null;

  final bool isLoading;
  final String? message;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return NeonPanel(
        width: double.infinity,
        child: Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: NeuralColors.tealDim,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              message!,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: NeuralColors.tealBorder,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            error!,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: const Color(0xFFFF4B6E),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onRetry,
          child: Text(
            'RETRY',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: NeuralColors.teal,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
