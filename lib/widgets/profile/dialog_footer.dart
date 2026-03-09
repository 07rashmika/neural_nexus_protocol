import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';

class DialogFooter extends StatelessWidget {
  const DialogFooter({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: .end,
        children: [
          GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: const .symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: .all(color: Colors.redAccent, width: 1.5),
                color: NeuralColors.bg2,
              ),
              child: Text(
                'logout'.toUpperCase(),
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
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
