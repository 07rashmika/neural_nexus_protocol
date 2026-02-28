import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/widgets/auth_form.dart';
import 'package:neural_nexus_protocol/widgets/swap_auth.dart';

import '../painters/scan_line.dart';
import '../providers/login_screen_provider.dart';
import '../widgets/circuit_background.dart';
import '../widgets/logo_box.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoGlowCtrl;

  late Animation<double> _logoGlow;

  Future<void> _submit({
    required String email,
    required String password,
    String? confirmPassword,
  }) async {
    // authorization
  }

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
  }

  @override
  void dispose() {
    _logoGlowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedInScreen = ref.watch(isLoginScreenProvider);

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
                    AnimatedBuilder(
                      animation: _logoGlow,
                      builder: (context, child) =>
                          LogoBox(glowOpacity: _logoGlow.value),
                    ),
                    AuthForm(onSubmit: _submit),
                    const SizedBox(height: 16),
                    const SwapAuth(),
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
