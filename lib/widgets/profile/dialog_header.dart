import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          // Avatar — SVG if available, fallback to initials
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
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
            padding: const EdgeInsets.all(4),
            child: agent.avatarUrl.isNotEmpty
                ? SvgPicture.network(
                    agent.avatarUrl,
                    placeholderBuilder: (_) => Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.spaceMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: NeuralColors.teal,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: NeuralColors.teal,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 14),

          // Username + callsign/position
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
                const SizedBox(height: 2),
                if (agent.callsign != null && agent.callsign!.isNotEmpty)
                  Text(
                    '"${agent.callsign}"',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: NeuralColors.teal,
                      letterSpacing: 1,
                    ),
                  ),
                const SizedBox(height: 2),
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

          // Close button
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