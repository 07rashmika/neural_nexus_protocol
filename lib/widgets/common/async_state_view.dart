import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView.loading({super.key, this.message = 'LOADING...'})
      : error = null,
        onRetry = null;

  const AsyncStateView.error({
    super.key,
    required this.error,
    required this.onRetry,
  }) : message = null;

  final String? message;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error!,
              style: GoogleFonts.spaceMono(
                color: Colors.redAccent,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'RETRY',
                style: GoogleFonts.spaceMono(
                  color: NeuralColors.teal,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: NeuralColors.tealDim,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message!,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: NeuralColors.tealBorder,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}