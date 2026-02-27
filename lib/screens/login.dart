import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/painters/scan_line.dart';
import 'package:neural_nexus_protocol/widgets/button.dart';

import 'package:neural_nexus_protocol/widgets/circuit_background.dart';
import 'package:neural_nexus_protocol/widgets/input_field.dart';
import 'package:neural_nexus_protocol/widgets/logo_box.dart';
import '../widgets/glow_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // animation controllers
  late AnimationController _logoGlowCtrl;
  late AnimationController _flickerCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _btnSweepCtrl;

  late Animation<double> _logoGlow;
  late Animation<double> _flicker;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _logoGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoGlow = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _logoGlowCtrl, curve: Curves.easeInOut));

    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _flicker = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 94),
      TweenSequenceItem(tween: Tween(begin: 1, end: .85), weight: .5),
      TweenSequenceItem(tween: ConstantTween(1), weight: .5),
      TweenSequenceItem(tween: Tween(begin: 1, end: .9), weight: .5),
      TweenSequenceItem(tween: ConstantTween(1), weight: 4.5),
    ]).animate(_flickerCtrl);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _btnSweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _logoGlowCtrl.dispose();
    _flickerCtrl.dispose();
    _pulseCtrl.dispose();
    _btnSweepCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CircuitBackground()),
          Positioned.fill(child: CustomPaint(painter: ScanLinePainter())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const .symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    // logo
                    AnimatedBuilder(
                      animation: _logoGlow,
                      builder: (context, child) =>
                          LogoBox(glowOpacity: _logoGlow.value),
                    ),

                    const SizedBox(height: 20),

                    AnimatedBuilder(
                      animation: _flicker,
                      builder: (context, child) => Opacity(
                        opacity: _flicker.value,
                        child: GlowText(
                          text: 'WELCOME BACK AGENT!',
                          fontWeight: .w900,
                          fontSize: 24,
                          letterSpacing: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    InputField(
                      label: 'email',
                      hint: 'email@domain.com',
                      obscure: false,
                      controller: _emailController,
                      keyBoardType: .emailAddress,
                    ),
                    InputField(
                      label: 'password',
                      hint: '********',
                      obscure: true,
                      controller: _passwordController,
                      keyBoardType: .visiblePassword,
                    ),

                    const SizedBox(height: 32),

                    Button(
                      sweepController: _btnSweepCtrl,
                      text: 'login',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
