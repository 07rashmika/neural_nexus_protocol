import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/painters/sweep.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.sweepController,
    required this.text,
    required this.onTap,
  });

  final AnimationController sweepController;
  final String text;
  final void Function() onTap;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _pressed = true;
        });
        widget.sweepController.forward(from: 0);
      },
      onTapUp: (details) => setState(() {
        _pressed = false;
      }),
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            _hovered = true;
          });
          widget.sweepController.forward(from: 0);
        },
        onExit: (event) => setState(() {
          _hovered = false;
        }),
        child: AnimatedBuilder(
          animation: widget.sweepController,
          builder: (context, child) {
            return AnimatedScale(
              scale: _pressed ? .97 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: .infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: _hovered
                      ? NeuralColors.teal.withValues(alpha: .08)
                      : Colors.transparent,
                  border: .all(color: NeuralColors.teal, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: NeuralColors.teal.withValues(
                        alpha: _hovered ? 0.35 : 0.12,
                      ),
                      blurRadius: _hovered ? 28 : 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: .center,
                  children: [
                    if (widget.sweepController.value > 0 &&
                        widget.sweepController.value < 1)
                      Positioned.fill(
                        child: ClipRect(
                          child: CustomPaint(
                            painter: SweepPainter(
                              progress: widget.sweepController.value,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      widget.text.toUpperCase(),
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: .w700,
                        color: NeuralColors.teal,
                        letterSpacing: 5,
                        shadows: _hovered
                            ? [
                                Shadow(
                                  color: NeuralColors.teal.withValues(
                                    alpha: .9,
                                  ),
                                  blurRadius: 12,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
