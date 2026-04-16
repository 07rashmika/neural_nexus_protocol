import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                color: NeuralColors.textDim,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(width: 1, height: 12, color: NeuralColors.tealBorder),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                color: valueColor ?? NeuralColors.textMain,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
