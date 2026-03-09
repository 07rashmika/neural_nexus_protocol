import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/missionSelect/status_icon.dart';

class NodeCard extends StatefulWidget {
  const NodeCard({required this.node, required this.onStart});

  final NodeModel node;
  final VoidCallback onStart;

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  bool _pressed = false;

  Color get _borderColor {
    if (widget.node.isCompleted) return Colors.greenAccent;
    if (widget.node.isCurrent) return NeuralColors.teal;
    if (widget.node.isLocked) {
      return NeuralColors.tealDark.withValues(alpha: 0.5);
    }
    return NeuralColors.teal;
  }

  Color get _difficultyColor {
    if (widget.node.isLocked) return NeuralColors.tealDark;
    return switch (widget.node.difficulty) {
      NodeDifficulty.standard => Colors.greenAccent,
      NodeDifficulty.secured => NeuralColors.teal,
      NodeDifficulty.critical => Colors.orangeAccent,
      NodeDifficulty.boss => Colors.redAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isLocked = node.isLocked;

    return GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _pressed = true),
      onTapUp: isLocked ? null : (_) => setState(() => _pressed = false),
      onTapCancel: isLocked ? null : () => setState(() => _pressed = false),
      onTap: isLocked ? null : widget.onStart,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: PixelBorder(
          color: _borderColor,
          glow: node.isCurrent,
          glowMin: 0.1,
          glowMax: 0.4,
          padding: .zero,
          child: Container(
            color: isLocked
                ? NeuralColors.bg2.withValues(alpha: 0.4)
                : NeuralColors.bg2,
            child: Column(
              children: [
                // ── Card body ────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const .fromLTRB(16, 20, 16, 12),
                    child: Column(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        // Node name
                        Text(
                          'Node ${node.nodeNumber}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: .w700,
                            color: isLocked
                                ? NeuralColors.tealDark
                                : _borderColor,
                            letterSpacing: 1.5,
                          ),
                        ),

                        // Difficulty
                        Text(
                          node.difficultyLabel,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: _difficultyColor,
                            letterSpacing: 1,
                          ),
                        ),

                        // Status icon
                        StatusIcon(node: node),
                      ],
                    ),
                  ),
                ),

                // ── Start button (current node only) ─────────────────
                if (node.isCurrent)
                  Container(
                    width: .infinity,
                    color: NeuralColors.teal,
                    padding: const .symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'START',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: .w700,
                          color: NeuralColors.bg,
                          letterSpacing: 3,
                        ),
                      ),
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


