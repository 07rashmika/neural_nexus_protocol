import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({
    super.key,
    required this.node,
    required this.puzzleIndex,
    required this.score,
    required this.timeLeft,
    required this.carrotsRemaining,
    required this.onResume,
    required this.onQuit,
  });

  final NodeModel node;
  final int puzzleIndex;
  final int score;
  final int timeLeft;
  final int carrotsRemaining;
  final VoidCallback onResume;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Blur backdrop ──────────────────────────────────────────
        Positioned.fill(
          child: BackdropFilter(
            filter: .blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: NeuralColors.bg.withValues(alpha: 0.75)),
          ),
        ),

        // ── Dialog card ────────────────────────────────────────────
        Center(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.82,
              child: PixelBorder(
                glow: false,
                color: NeuralColors.teal,
                padding: const .fromLTRB(28, 32, 28, 28),
                child: ColoredBox(
                  color: NeuralColors.bg2,
                  child: Padding(
                    padding: const .all(12.0),
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        // title
                        GlowText(
                          text: 'paused',
                          fontSize: 18,
                          fontWeight: .w600,
                          letterSpacing: 2,
                        ),
                        Divider(),
                        Text(
                          'Node ${node.nodeNumber}  ·  ${node.difficultyLabel.toUpperCase()}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            color: NeuralColors.tealDim,
                            letterSpacing: 2,
                          ),
                        ),

                        Divider(),

                        Divider(),

                        // stats
                        InfoRow(
                          label: 'Puzzle',
                          value: '${puzzleIndex + 1} / ${node.puzzleCount}',
                        ),
                        InfoRow(label: 'Score', value: '$score pts'),
                        InfoRow(label: 'Time', value: '${timeLeft}s remaining'),
                        InfoRow(label: 'Hints', value: '🥕 x$carrotsRemaining'),

                        const SizedBox(height: 28),

                        // Resume button
                        Button(text: 'Resume', onTap: onResume),

                        const SizedBox(height: 16),

                        // Quit link
                        GestureDetector(
                          onTap: onQuit,
                          child: PixelBorder(
                            color: const Color(0xFFFF4B6E),
                            borderWidth: 1,
                            bracketSize: 8,
                            bracketThickness: 1.5,
                            padding: const .symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: ColoredBox(
                              color: const Color(
                                0xFFFF4B6E,
                              ).withValues(alpha: 0.05),
                              child: Center(
                                child: Text(
                                  'QUIT NODE',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    color: const Color(0xFFFF4B6E),
                                    letterSpacing: 3,
                                    fontWeight: .w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}