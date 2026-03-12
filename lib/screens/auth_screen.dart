import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/screens/loading_screen.dart';
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
  // Error is stored here so AuthForm can display it after loading screen pops
  String? _authError;

  @override
  Widget build(BuildContext context) {
    final isLoginScreen = ref.watch(isLoginScreenProvider);

    Future<void> submit({
      required String email,
      required String password,
      String? confirmPassword,
      String? username,
    }) async {
      // Clear previous error
      setState(() => _authError = null);

      if (isLoginScreen) {
        // Show loading screen immediately
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (_, __, ___) =>
                const LoadingScreen(message: 'loading...'),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );

        try {
          final res = await ApiService.login(email: email, password: password);
          if (!res['success']) throw Exception(res['message']);
          final agent = await ApiService.getProfile();
          ref.read(agentProvider.notifier).state = agent;

          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        } on Exception catch (e) {
          // Pop loading screen, show error back on auth screen
          if (mounted) Navigator.of(context).pop();
          throw e; // re-throw so AuthForm's catch shows it
        }
      } else {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (_, __, ___) =>
                const LoadingScreen(message: 'creating agent...'),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );

        try {
          final res = await ApiService.register(
            email: email,
            password: password,
            confirmPassword: confirmPassword!,
          );
          if (!res['success']) throw Exception(res['message']);

          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/profile-setup', (route) => false);
        } on Exception catch (e) {
          if (mounted) Navigator.of(context).pop();
          throw e;
        }
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