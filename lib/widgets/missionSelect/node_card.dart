import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/missionSelect/status_icon.dart';

class NodeCard extends StatefulWidget {
  const NodeCard({super.key, required this.node, required this.onStart});
  final NodeModel node;
  final VoidCallback onStart;

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  bool _pressed = false;

  bool get _tappable => widget.node.isCurrent;

  Color get _borderColor {
    if (widget.node.isCompleted) return Colors.greenAccent;
    if (widget.node.isCurrent) return _difficultyColor;
    return NeuralColors.tealDark.withValues(alpha: 0.4);
  }

  Color get _difficultyColor => switch (widget.node.difficulty) {
    NodeDifficulty.standard => Colors.greenAccent,
    NodeDifficulty.secured => NeuralColors.teal,
    NodeDifficulty.critical => const Color(0xFFFFB347),
    NodeDifficulty.boss => const Color(0xFFFF4B6E),
  };

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isLocked = node.isLocked;

    return GestureDetector(
      onTapDown: _tappable ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _tappable ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _tappable ? () => setState(() => _pressed = false) : null,
      onTap: _tappable ? widget.onStart : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: PixelBorder(
          color: _borderColor,
          glow: node.isCurrent,
          glowMin: 0.1,
          glowMax: 0.4,
          padding: EdgeInsets.zero,
          child: Container(
            color: isLocked
                ? NeuralColors.bg2.withValues(alpha: 0.4)
                : NeuralColors.bg2,
            child: Column(
              children: [
                // ── Card body ─────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Node name
                        Text(
                          'Node ${node.nodeNumber}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isLocked
                                ? NeuralColors.tealDark
                                : _borderColor,
                            letterSpacing: 1.5,
                          ),
                        ),

                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isLocked
                                  ? NeuralColors.tealDark.withValues(alpha: 0.4)
                                  : _difficultyColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            node.difficultyLabel.toUpperCase(),
                            style: GoogleFonts.spaceMono(
                              fontSize: 8,
                              color: isLocked
                                  ? NeuralColors.tealDark
                                  : _difficultyColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        // Rules label (2 puzzles · 30s)
                        Text(
                          node.rulesLabel,
                          style: GoogleFonts.spaceMono(
                            fontSize: 8,
                            color: isLocked
                                ? NeuralColors.tealDark.withValues(alpha: 0.5)
                                : NeuralColors.tealDim,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Status icon
                        StatusIcon(node: node),
                      ],
                    ),
                  ),
                ),

                // ── Start button (current node only) ──────────────────
                if (node.isCurrent)
                  Container(
                    width: double.infinity,
                    color: _difficultyColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'INFILTRATE',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: NeuralColors.bg,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                // ── Completed stamp ───────────────────────────────────
                if (node.isCompleted)
                  Container(
                    width: double.infinity,
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        '✓ CLEARED',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.greenAccent,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                // ── Locked indicator ──────────────────────────────────
                if (node.isLocked)
                  Container(
                    width: double.infinity,
                    color: NeuralColors.tealDark.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: NeuralColors.tealDark,
                          size: 10,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LOCKED',
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            color: NeuralColors.tealDark,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
