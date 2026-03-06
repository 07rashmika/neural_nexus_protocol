import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.text,
    required this.onTap,
  });

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
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: _hovered
                  ? NeuralColors.teal.withValues(alpha: .08)
                  : Colors.transparent,
              border: Border.all(color: NeuralColors.teal, width: 1.5),
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
            child: Center(
              child: Text(
                widget.text.toUpperCase(),
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NeuralColors.teal,
                  letterSpacing: 5,
                  shadows: _hovered
                      ? [
                          Shadow(
                            color: NeuralColors.teal.withValues(alpha: .9),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}