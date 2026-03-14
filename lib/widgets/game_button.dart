import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';

import '../painters/game_button_border_painter.dart';
import '../painters/scan_line.dart';

class GameButton extends StatefulWidget {
  const GameButton({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _flashing = false;

  late AnimationController _cursorCtrl;
  late Animation<double> _cursorBlink;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _cursorBlink = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 50),
    ]).animate(_cursorCtrl);
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await AppAudioService.instance.playButtonTap();

    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() => _flashing = i.isEven);
      await Future.delayed(const Duration(milliseconds: 75));
    }

    if (mounted) {
      setState(() => _flashing = false);
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 40),
        transform: _pressed
            ? (Matrix4.identity()..translateByDouble(2.0, 2.0, 0.0, 0.0))
            : Matrix4.identity(),
        child: CustomPaint(
          painter: GameButtonBorderPainter(pressed: _pressed),
          child: Padding(
            padding: const .symmetric(horizontal: 32, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel(),
                const SizedBox(width: 6),
                // blinking cursor block
                AnimatedBuilder(
                  animation: _cursorBlink,
                  builder: (_, _) => Opacity(
                    opacity: _cursorBlink.value,
                    child: Container(
                      width: 10,
                      height: 14,
                      color: _flashing ? NeuralColors.bg : NeuralColors.teal,
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

  Widget _buildLabel() {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: ScanLinePainter())),
        ),
        Text(
          widget.text.toUpperCase(),
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: _flashing ? NeuralColors.bg : NeuralColors.textMain,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: NeuralColors.teal.withValues(alpha: .6),
                blurRadius: 10,
              ),
              const Shadow(color: Colors.transparent, offset: Offset(2, 2)),
            ],
          ),
        ),
      ],
    );
  }
}
