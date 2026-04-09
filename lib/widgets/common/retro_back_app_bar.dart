import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';

class RetroBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RetroBackAppBar({
    super.key,
    required this.title,
    this.titleFontSize = 14,
    this.titleLetterSpacing = 4,
    this.titleFontWeight = FontWeight.w700,
    this.leadingPadding = const EdgeInsets.only(left: 16),
    this.backFontSize = 22,
  });

  final String title;
  final double titleFontSize;
  final double titleLetterSpacing;
  final FontWeight titleFontWeight;
  final EdgeInsetsGeometry leadingPadding;
  final double backFontSize;

  @override
  Size get preferredSize => const Size.fromHeight(81.5);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      leading: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: leadingPadding,
          child: GestureDetector(
            onTap: () async {
              await AppAudioService.instance.playButtonTap();
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  color: NeuralColors.tealDim,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'BACK',
                  style: GoogleFonts.spaceMono(
                    fontSize: backFontSize,
                    color: NeuralColors.tealDim,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: GlowText(
        text: title,
        fontSize: titleFontSize,
        fontWeight: titleFontWeight,
        letterSpacing: titleLetterSpacing,
      ),
      centerTitle: true,
      backgroundColor: NeuralColors.bg2,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Container(height: 1.5, color: NeuralColors.teal),
      ),
    );
  }
}
