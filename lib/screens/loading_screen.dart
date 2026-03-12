import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, this.message = 'connecting...'});

  final String message;

  /// Push this screen and replace current route.
  /// When [future] completes it navigates to [nextRoute].
  static Future<void> navigate({
    required BuildContext context,
    required Future<void> Function() action,
    required String nextRoute,
    Object? arguments,
    String message = 'connecting...',
  }) async {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoadingScreen(message: message),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    try {
      await action();
    } finally {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          nextRoute,
          (route) => false,
          arguments: arguments,
        );
      }
    }
  }

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  int _dotCount = 1;
  late final _dotTimer =
      Stream.periodic(
        const Duration(milliseconds: 500),
        (i) => (i % 3) + 1,
      ).listen((d) {
        if (mounted) setState(() => _dotCount = d);
      });

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _dotTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: NeuralColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Pulsing logo / icon ───────────────────────────────
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Opacity(
                opacity: _pulse.value,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: NeuralColors.teal.withValues(alpha: _pulse.value),
                      width: 1.5,
                    ),
                    color: NeuralColors.teal.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: NeuralColors.teal.withValues(
                          alpha: _pulse.value * 0.3,
                        ),
                        blurRadius: 24,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'NN',
                      style: GoogleFonts.spaceMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: NeuralColors.teal.withValues(
                          alpha: _pulse.value,
                        ),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Message ───────────────────────────────────────────
            GlowText(
              text: widget.message.toUpperCase(),
              fontSize: 12,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),

            const SizedBox(height: 8),

            // ── Animated dots ─────────────────────────────────────
            Text(
              dots,
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                color: NeuralColors.tealDim,
                letterSpacing: 6,
              ),
            ),

            const SizedBox(height: 32),

            // ── Progress bar ──────────────────────────────────────
            SizedBox(
              width: 120,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, _) => LinearProgressIndicator(
                  backgroundColor: NeuralColors.tealDark,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    NeuralColors.teal.withValues(alpha: _pulse.value),
                  ),
                  minHeight: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
