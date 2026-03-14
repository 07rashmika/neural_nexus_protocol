import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class AvatarFrame extends StatelessWidget {
  const AvatarFrame({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 40,
    this.padding = const EdgeInsets.all(4),
    this.borderColor = NeuralColors.teal,
    this.backgroundColor = NeuralColors.bg2,
    this.fit = BoxFit.contain,
    this.glowOpacity = 0.25,
    this.borderWidth = 1.5,
    this.fallbackFontSize,
    this.placeholder,
  });

  final String? imageUrl;
  final String fallbackText;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color backgroundColor;
  final BoxFit fit;
  final double glowOpacity;
  final double borderWidth;
  final double? fallbackFontSize;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        fallbackText,
        style: GoogleFonts.spaceMono(
          fontSize: fallbackFontSize ?? (size * 0.3),
          fontWeight: FontWeight.w700,
          color: borderColor,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: glowOpacity),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? SvgPicture.network(
              imageUrl!,
              fit: fit,
              placeholderBuilder: (_) => placeholder ?? fallback,
            )
          : fallback,
    );
  }
}
