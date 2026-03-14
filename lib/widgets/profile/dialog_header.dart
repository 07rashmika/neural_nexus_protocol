import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../models/agent.dart';
import '../common/avatar_frame.dart';

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
          AvatarFrame(
            imageUrl: agent.avatarUrl,
            fallbackText: initials,
            size: 56,
            fallbackFontSize: 16,
            glowOpacity: 0.3,
          ),
          const SizedBox(width: 14),
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