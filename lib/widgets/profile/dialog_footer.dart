import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';

class DialogFooter extends StatelessWidget {
  const DialogFooter({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: .end,
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const .symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: .all(color: NeuralColors.teal, width: 1.5),
                color: NeuralColors.bg2,
              ),
              child: Text(
                'CLOSE',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: .w700,
                  color: NeuralColors.teal,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
