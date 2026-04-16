import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

class StatBar extends StatelessWidget {
  const StatBar({super.key, 
    required this.label,
    required this.rawValue,
    required this.displayValue,
    required this.maxValue,
  });

  final String label;
  final double rawValue;
  final String displayValue;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final fraction = (rawValue / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const .symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: NeuralColors.textDim,
                  letterSpacing: 1,
                ),
              ),
              Text(
                displayValue,
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: NeuralColors.teal,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: NeuralColors.tealBorder,
                  borderRadius: .circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: NeuralColors.teal,
                    borderRadius: .circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: NeuralColors.teal.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
