import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class PixelBorder extends StatefulWidget {
  const PixelBorder({
    super.key,
    required this.child,
    this.glow = false,
    this.color = NeuralColors.teal,
    this.borderWidth = 1.5,
    this.bracketSize = 10.0,
    this.bracketThickness = 2.0,
    this.bracketOffset = -8.0,
    this.glowMin = 0.2,
    this.glowMax = 0.6,
    this.glowDuration = const Duration(seconds: 3),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  final Widget child;
  final bool glow;
  final Color color;
  final double borderWidth;
  final double bracketSize;
  final double bracketThickness;
  final double bracketOffset;
  final double glowMin;
  final double glowMax;
  final Duration glowDuration;
  final EdgeInsetsGeometry padding;

  @override
  State<PixelBorder> createState() => _PixelBorderState();
}

class _PixelBorderState extends State<PixelBorder>
    with SingleTickerProviderStateMixin {
  AnimationController? _glowCtrl;
  Animation<double>? _glow;

  @override
  void initState() {
    super.initState();
    if (widget.glow) _initGlow();
  }

  @override
  void didUpdateWidget(PixelBorder old) {
    super.didUpdateWidget(old);
    if (widget.glow && _glowCtrl == null) {
      _initGlow();
    } else if (!widget.glow && _glowCtrl != null) {
      _glowCtrl!.dispose();
      _glowCtrl = null;
      _glow = null;
    }
  }

  void _initGlow() {
    _glowCtrl = AnimationController(vsync: this, duration: widget.glowDuration)
      ..repeat(reverse: true);

    _glow = Tween<double>(
      begin: widget.glowMin,
      end: widget.glowMax,
    ).animate(CurvedAnimation(parent: _glowCtrl!, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.glow && _glow != null) {
      return AnimatedBuilder(
        animation: _glow!,
        builder: (context, _) => _buildContainer(_glow!.value),
      );
    }
    return _buildContainer(0);
  }

  Widget _buildContainer(double glowOpacity) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: .all(color: widget.color, width: widget.borderWidth),
        boxShadow: widget.glow
            ? [
                BoxShadow(
                  color: widget.color.withValues(alpha: glowOpacity),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: widget.color.withValues(alpha: glowOpacity * 0.3),
                  blurRadius: 50,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: Stack(
        clipBehavior: .none,
        children: [..._buildBrackets(), widget.child],
      ),
    );
  }

  List<Widget> _buildBrackets() {
    final o = widget.bracketOffset;
    final size = widget.bracketSize;
    final thickness = widget.bracketThickness;
    final color = widget.color;

    Widget bracket({
      double? top,
      double? bottom,
      double? left,
      double? right,
      required Border border,
    }) => Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: border),
      ),
    );

    return [
      bracket(
        top: o,
        left: o,
        border: Border(
          top: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
        ),
      ),
      bracket(
        top: o,
        right: o,
        border: Border(
          top: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        ),
      ),
      bracket(
        bottom: o,
        left: o,
        border: Border(
          bottom: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
        ),
      ),
      bracket(
        bottom: o,
        right: o,
        border: Border(
          bottom: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        ),
      ),
    ];
  }
}
