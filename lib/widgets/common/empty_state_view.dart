import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.spaceMono(
          fontSize: 11,
          color: NeuralColors.tealDim,
          letterSpacing: 3,
        ),
      ),
    );
  }
}