import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/sector.dart';
import 'package:neural_nexus_protocol/screens/mission_select_screen.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/sectorMap/node_dots.dart';

class SectorCard extends StatefulWidget {
  const SectorCard({super.key, required this.sector, required this.onReturn});

  final Sector sector;
  final VoidCallback onReturn;

  @override
  State<SectorCard> createState() => _SectorCardState();
}

class _SectorCardState extends State<SectorCard> {
  bool _pressed = false;

  Color get _borderColor {
    switch (widget.sector.status) {
      case .completed:
        return Colors.greenAccent;
      case .partial:
      case .available:
        return NeuralColors.teal;
      case .locked:
        return NeuralColors.tealDark;
    }
  }

  bool get _isLocked => widget.sector.status == .locked;

  @override
  Widget build(BuildContext context) {
    final s = widget.sector;
    return Padding(
      padding: const .only(bottom: 32),
      child: GestureDetector(
        onTapDown: _isLocked ? null : (_) => setState(() => _pressed = true),
        onTapUp: _isLocked ? null : (_) => setState(() => _pressed = false),
        onTapCancel: _isLocked ? null : () => setState(() => _pressed = false),
        onTap: _isLocked
            ? null
            : () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MissionSelectScreen(sector: widget.sector),
                      ),
                    )
                    .then((_) => widget.onReturn()); // ← call it on return
              },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: PixelBorder(
            color: _borderColor,
            glow: s.status == .completed,
            glowMin: 0.15,
            glowMax: 0.45,
            padding: .zero,
            child: Container(
              color: _isLocked
                  ? NeuralColors.bg2.withValues(alpha: 0.5)
                  : NeuralColors.bg2,
              child: Column(
                children: [
                  Padding(
                    padding: const .fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          s.name.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontSize: 13,
                            fontWeight: .w700,
                            color: _isLocked
                                ? NeuralColors.tealDark
                                : _borderColor,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.subtitle,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            color: _isLocked
                                ? NeuralColors.tealDark
                                : NeuralColors.tealDim,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_isLocked) ...[
                          Text(
                            'LOCKED',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 13,
                              color: NeuralColors.tealDark,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (s.unlockRequirement != null)
                            Row(
                              mainAxisAlignment: .center,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 11,
                                  color: NeuralColors.tealDark,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.unlockRequirement!,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 10,
                                    color: NeuralColors.tealDark,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 32),
                        ] else ...[
                          Text(
                            '${s.completedNodes}/${s.totalNodes} Nodes',
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              color: NeuralColors.textMain,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          NodeDots(
                            total: s.totalNodes,
                            completed: s.completedNodes,
                            color: _borderColor,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                  if (!_isLocked)
                    Container(
                      width: .infinity,
                      color: NeuralColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text(
                          'SELECT SECTOR',
                          style: GoogleFonts.spaceMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
