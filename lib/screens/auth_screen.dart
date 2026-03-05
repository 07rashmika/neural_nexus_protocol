import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/widgets/authentication/auth_form.dart';
import 'package:neural_nexus_protocol/widgets/authentication/swap_auth.dart';

import '../painters/scan_line.dart';
import '../providers/login_screen_provider.dart';
import '../widgets/circuit_background.dart';
import '../widgets/logo_box.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  Future<void> _submit({
    required String email,
    required String password,
    String? confirmPassword,
  }) async {}

  @override
  Widget build(BuildContext context) {
    final isLoggedInScreen = ref.watch(isLoginScreenProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    const LogoBox(),
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
