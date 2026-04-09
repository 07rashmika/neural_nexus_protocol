import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class GameScreenHeader extends StatelessWidget {
  const GameScreenHeader({
    super.key,
    required this.shields,
    required this.agent,
    required this.node,
    required this.livesLeft,
    required this.score,
    required this.nodeDone,
    required this.onPause,
  });

  final ShieldState shields;
  final Agent? agent;
  final NodeModel node;
  final int livesLeft;
  final int score;
  final bool nodeDone;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShieldCount(count: shields.count, max: ShieldState.max),
        const SizedBox(width: 10),
        if (agent != null)
          Text(
            '${agent!.intelPoints.toStringAsFixed(0)} IP',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: NeuralColors.tealDim,
              letterSpacing: 1,
            ),
          ),
        const Spacer(),
        if (node.lives > 0) ...[
          Row(
            children: List.generate(node.lives + 1, (i) {
              final spent = i > livesLeft;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  spent ? Icons.favorite_border : Icons.favorite,
                  color: spent
                      ? NeuralColors.tealDark
                      : const Color(0xFFFF4B6E),
                  size: 14,
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          '$score',
          style: GoogleFonts.spaceMono(
            fontSize: 13,
            color: NeuralColors.teal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        if (!nodeDone)
          GestureDetector(
            onTap: onPause,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: NeuralColors.tealDark),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.pause,
                color: NeuralColors.tealDim,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}
