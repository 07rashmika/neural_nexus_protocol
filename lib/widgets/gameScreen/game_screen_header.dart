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
    required this.chainMultiplier,
    required this.nodeDone,
    required this.onPause,
  });

  final ShieldState shields;
  final Agent? agent;
  final NodeModel node;
  final int livesLeft;
  final int score;
  final int chainMultiplier;
  final bool nodeDone;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final chainActive = chainMultiplier > 1;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey(
                  livesLeft,
                ), // re-triggers shake each time lives drop
                tween: Tween(begin: 1.0, end: 0.0),
                duration: const Duration(milliseconds: 400),
                builder: (context, t, child) {
                  final offset = livesLeft == 1
                      ? (t < 0.5 ? (t * 8 - 2) : ((1 - t) * 8 - 2))
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Row(
                  children: List.generate(node.lives + 1, (i) {
                    final spent = i > livesLeft;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        spent ? Icons.favorite_border : Icons.favorite,
                        color: livesLeft == 1
                            ? const Color(0xFFFF4B6E) // pulse red on last life
                            : spent
                            ? NeuralColors.tealDark
                            : const Color(0xFFFF4B6E),
                        size: 14,
                      ),
                    );
                  }),
                ),
              ),
              if (livesLeft == 1)
                Text(
                  'LAST LIFE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 7,
                    color: const Color(0xFFFF4B6E),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
        ],

        if (chainActive) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: chainMultiplier >= 5
                    ? const Color(0xFFFF4B6E)
                    : const Color(0xFFFFB347),
              ),
            ),
            child: Text(
              chainMultiplier >= 5
                  ? '🔥x$chainMultiplier'
                  : '⚡x$chainMultiplier',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: chainMultiplier >= 5
                    ? const Color(0xFFFF4B6E)
                    : const Color(0xFFFFB347),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
