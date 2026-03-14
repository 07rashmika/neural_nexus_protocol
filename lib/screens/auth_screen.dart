import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/screens/profile_setup_screen.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/authentication/auth_form.dart';
import 'package:neural_nexus_protocol/widgets/authentication/swap_auth.dart';

import '../painters/scan_line.dart';
import '../providers/login_screen_provider.dart';
import '../widgets/circuit_background.dart';
import '../widgets/common/logo_box.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final isLoginScreen = ref.watch(isLoginScreenProvider);

    Future<void> submit({
      required String email,
      required String password,
      String? confirmPassword,
      String? username,
    }) async {
      if (isLoginScreen) {
        final res = await ApiService.login(email: email, password: password);
        if (!res['success']) throw Exception(res['message']);

        final agent = await ApiService.getProfile();
        ref.read(agentProvider.notifier).state = agent;

        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        final res = await ApiService.register(
          email: email,
          password: password,
          confirmPassword: confirmPassword!,
        );
        if (!res['success']) throw Exception(res['message']);

        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: CircuitBackground()),
          Positioned.fill(child: CustomPaint(painter: ScanLinePainter())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    const LogoBox(),
                    AuthForm(onSubmit: submit),
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
