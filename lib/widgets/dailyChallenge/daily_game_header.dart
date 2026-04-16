import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class DailyGameHeader extends StatelessWidget {
  const DailyGameHeader({
    super.key,
    required this.shields,
    required this.score,
  });

  final ShieldState shields;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShieldCount(count: shields.count, max: ShieldState.max),
        const SizedBox(width: 8),
        Text(
          'DAILY',
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            color: const Color(0xFFFFB347),
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '$score',
          style: GoogleFonts.spaceMono(
            fontSize: 13,
            color: NeuralColors.teal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
