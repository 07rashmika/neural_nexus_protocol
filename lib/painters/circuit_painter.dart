//claude code
import 'package:flutter/cupertino.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

class CircuitPainter extends CustomPainter {
  CircuitPainter({required this.progress});

  final double progress;

  static const teal = NeuralColors.teal;

  // circuit paths in a list of points
  static final List<List<Offset>> _paths = [
    [
      const Offset(0, 0.1),
      const Offset(0.22, 0.1),
      const Offset(0.22, 0.19),
      const Offset(0.40, 0.19),
      const Offset(0.40, 0.1),
      const Offset(0.70, 0.1),
      const Offset(0.70, 0.25),
      const Offset(1.0, 0.25),
    ],
    [
      const Offset(0, 0.38),
      const Offset(0.12, 0.38),
      const Offset(0.12, 0.48),
      const Offset(0.35, 0.48),
      const Offset(0.35, 0.38),
      const Offset(0.60, 0.38),
      const Offset(0.60, 0.57),
      const Offset(1.0, 0.57),
    ],
    [
      const Offset(0, 0.63),
      const Offset(0.18, 0.63),
      const Offset(0.18, 0.75),
      const Offset(0.50, 0.75),
      const Offset(0.50, 0.63),
      const Offset(0.80, 0.63),
      const Offset(0.80, 0.88),
      const Offset(1.0, 0.88),
    ],

    [
      const Offset(0.75, 0),
      const Offset(0.75, 0.15),
      const Offset(0.90, 0.15),
      const Offset(0.90, 0.38),
      const Offset(1.0, 0.38),
    ],
    [
      const Offset(0.05, 0),
      const Offset(0.05, 0.25),
      const Offset(0.15, 0.25),
      const Offset(0.15, 0.50),
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = teal.withValues(alpha: .22)
      ..strokeWidth = 2
      ..style = .stroke;

    final nodePaint = Paint()
      ..color = teal.withValues(alpha: .4)
      ..style = .fill;

    // Circuit paths
    for (final path in _paths) {
      final points = path
          .map((p) => Offset(p.dx * size.width, p.dy * size.height))
          .toList();
      final p = Path();

      p.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        p.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(p, linePaint);

      for (int i = 1; i < points.length - 1; i++) {
        canvas.drawCircle(points[i], 3, nodePaint);
      }
    }

    // pulse dots
    for (int pi = 0; pi < _paths.length; pi++) {
      final path = _paths[pi];
      final offset = (pi * .2) % 1.0;
      final t = (progress + offset) % 1.0;

      // total path length calculation
      double totalLength = 0;
      final pts = path
          .map((p) => Offset(p.dx * size.width, p.dy * size.height))
          .toList();

      for (int i = 0; i < pts.length - 1; i++) {
        totalLength += (pts[i + 1] - pts[i]).distance;
      }

      // position at t
      double target = t * totalLength;
      double cumLength = 0;
      Offset? dotPosition;

      for (int i = 0; i < pts.length - 1; i++) {
        final segmentLength = (pts[i + 1] - pts[i]).distance;

        if (cumLength + segmentLength >= target) {
          final segT = (target - cumLength) / segmentLength;
          dotPosition = Offset.lerp(pts[i], pts[i + 1], segT)!;
          break;
        }
        cumLength += segmentLength;
      }

      if (dotPosition != null) {
        final fade = t < 0.1 ? t / 0.1 : (t > 0.9 ? (1 - t) / 0.1 : 1.0);
        final glowPaint = Paint()
          ..color = teal.withValues(alpha: .8 * fade)
          ..maskFilter = const .blur(.normal, 6);

        canvas.drawCircle(dotPosition, 4, glowPaint);
        canvas.drawCircle(
          dotPosition,
          2.5,
          Paint()..color = teal.withValues(alpha: fade),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CircuitPainter old) => old.progress != progress;
}
