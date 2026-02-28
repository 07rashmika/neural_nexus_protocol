import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.controller,
    required this.keyBoardType,
    this.validator,
  });

  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController controller;
  final TextInputType keyBoardType;
  final String? Function(String?)? validator;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 1, color: NeuralColors.tealDim),
            const SizedBox(width: 6),
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 18,
                fontWeight: .w600,
                color: NeuralColors.tealDim,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (value) => setState(() {
            _focused = value;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: _focused
                  ? NeuralColors.teal.withValues(alpha: .06)
                  : NeuralColors.teal.withValues(alpha: .02),
              border: Border(
                top: BorderSide(color: NeuralColors.tealBorder, width: 1),
                left: BorderSide(color: NeuralColors.tealBorder, width: 1),
                right: BorderSide(color: NeuralColors.tealBorder, width: 1),
                bottom: BorderSide(
                  color: _focused
                      ? NeuralColors.tealDim
                      : NeuralColors.tealDark,
                  width: _focused ? 1.5 : 1,
                ),
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: NeuralColors.teal.withValues(alpha: .08),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              validator: widget.validator,
              keyboardType: widget.keyBoardType,
              controller: widget.controller,
              obscureText: widget.obscure,
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                color: NeuralColors.textMain,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.spaceMono(
                  fontSize: 14,
                  color: NeuralColors.tealBorder.withValues(alpha: 1.5),
                  letterSpacing: 1.5,
                ),
                border: .none,
                contentPadding: const .symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: NeuralColors.teal,
            ),
          ),
        ),
      ],
    );
  }
}
