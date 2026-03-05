import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../models/agent.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({super.key, required this.agent});

  final Agent agent;

  @override
  Widget build(BuildContext context) {
    final initials = agent.username.length >= 2
        ? agent.username.substring(0, 2).toUpperCase()
        : agent.username.toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeuralColors.teal, width: 1.5),
              color: NeuralColors.bg2,
              boxShadow: [
                BoxShadow(
                  color: NeuralColors.teal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.spaceMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NeuralColors.teal,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Username + position
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.username.toUpperCase(),
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NeuralColors.textMain,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: NeuralColors.teal.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agent.position.toUpperCase(),
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: NeuralColors.tealDim,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Close
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              color: NeuralColors.tealDim,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
