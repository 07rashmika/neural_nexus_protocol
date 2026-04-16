//claude code
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class GameButtonBorderPainter extends CustomPainter {
  const GameButtonBorderPainter({required this.pressed});

  final bool pressed;

  static const _b = 3.0; // border thickness
  static const _c = 4.0; // corner cut size

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    //background fill
    final bgPaint = Paint()..color = NeuralColors.bg;
    canvas.drawPath(_pixelRect(0, 0, w, h), bgPaint);

    //outer border
    final borderPaint = Paint()..color = NeuralColors.teal;
    canvas.drawRect(.fromLTWH(_c, 0, w - _c * 2, _b), borderPaint); // top
    canvas.drawRect(
      .fromLTWH(_c, h - _b, w - _c * 2, _b),
      borderPaint,
    ); // bottom
    canvas.drawRect(.fromLTWH(0, _c, _b, h - _c * 2), borderPaint); // left
    canvas.drawRect(
      .fromLTWH(w - _b, _c, _b, h - _c * 2),
      borderPaint,
    ); // right

    //inner bevel
    //top left: tealDim on normal, tealDark on press(shadow flips on press)
    final highlightPaint = Paint()
      ..color = pressed ? NeuralColors.tealDark : NeuralColors.tealDim;
    final shadowPaint = Paint()
      ..color = pressed ? NeuralColors.tealDim : NeuralColors.tealDark;

    canvas.drawRect(
      .fromLTWH(_b, _b, w - _b * 2, _b),
      highlightPaint,
    ); // top inner
    canvas.drawRect(
      .fromLTWH(_b, _b, _b, h - _b * 2),
      highlightPaint,
    ); // left inner

    canvas.drawRect(
      .fromLTWH(_b, h - _b * 2, w - _b * 2, _b),
      shadowPaint,
    ); // bottom inner
    canvas.drawRect(
      .fromLTWH(w - _b * 2, _b, _b, h - _b * 2),
      shadowPaint,
    ); // right inner

    //corner squares (pixel-art chamfered corners)
    final cornerPaint = Paint()..color = NeuralColors.tealBorder;
    canvas.drawRect(.fromLTWH(0, 0, _c, _c), cornerPaint); // top left
    canvas.drawRect(.fromLTWH(w - _c, 0, _c, _c), cornerPaint); // top right
    canvas.drawRect(.fromLTWH(0, h - _c, _c, _c), cornerPaint); // bottom left
    canvas.drawRect(
      .fromLTWH(w - _c, h - _c, _c, _c),
      cornerPaint,
    ); // bottom right

    //outermost corner cutouts (paint over with page bg)
    final cutPaint = Paint()..color = NeuralColors.bg2;
    const cut = 3.0;
    canvas.drawRect(.fromLTWH(0, 0, cut, cut), cutPaint);
    canvas.drawRect(.fromLTWH(w - cut, 0, cut, cut), cutPaint);
    canvas.drawRect(.fromLTWH(0, h - cut, cut, cut), cutPaint);
    canvas.drawRect(.fromLTWH(w - cut, h - cut, cut, cut), cutPaint);

    //hard drop shadow (tealDark offset)
    if (!pressed) {
      final dropPaint = Paint()..color = NeuralColors.tealDark;
      const d = 4.0;
      canvas.drawRect(.fromLTWH(w, _c + d, d, h - _c * 2), dropPaint); // right
      canvas.drawRect(.fromLTWH(_c + d, h, w - _c * 2, d), dropPaint); // bottom
    }
  }

  Path _pixelRect(double x, double y, double w, double h) {
    return Path()
      ..moveTo(x + _c, y)
      ..lineTo(x + w - _c, y)
      ..lineTo(x + w, y + _c)
      ..lineTo(x + w, y + h - _c)
      ..lineTo(x + w - _c, y + h)
      ..lineTo(x + _c, y + h)
      ..lineTo(x, y + h - _c)
      ..lineTo(x, y + _c)
      ..close();
  }

  @override
  bool shouldRepaint(GameButtonBorderPainter old) => old.pressed != pressed;
}
