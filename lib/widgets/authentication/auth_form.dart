import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neural_nexus_protocol/screens/home_screen.dart';
import '../../providers/login_screen_provider.dart';
import '../button.dart';
import '../glow_text.dart';
import 'input_field.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key, required this.onSubmit});

  final Future<void> Function({
    required String email,
    required String password,
    String? confirmPassword,
  })
  onSubmit;

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm>
    with TickerProviderStateMixin {
  late AnimationController _flickerCtrl;
  late AnimationController _btnSweepCtrl;

  late Animation<double> _flicker;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _flicker = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 94),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 0.5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 0.5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 4.5),
    ]).animate(_flickerCtrl);

    _btnSweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flickerCtrl.dispose();
    _btnSweepCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedInScreen = ref.watch(isLoginScreenProvider);

    Future<void> handleSubmit() async {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = isLoggedInScreen
          ? null
          : _confirmPasswordController.text;

      // need more work here later
      await widget.onSubmit(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // redirection to home
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }

    final glowTitle = isLoggedInScreen
        ? 'WELCOME BACK AGENT!'
        : 'WELCOME AGENT!';
    final buttonText = isLoggedInScreen ? 'LOGIN' : 'REGISTER';

    String? emailValidator(String? value) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return 'Email is required';
      final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
      if (!emailOk) return 'Enter a valid email';
      return null;
    }

    String? passwordValidator(String? value) {
      final v = value ?? '';
      if (v.isEmpty) return 'Password is required';
      if (v.length < 6) return 'Use at least 6 characters';
      return null;
    }

    String? confirmPasswordValidator(String? value) {
      if (isLoggedInScreen) return null;
      final v = value ?? '';
      if (v.isEmpty) return 'Confirm your password';
      if (v != _passwordController.text) return 'Passwords do not match';
      return null;
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),

          AnimatedBuilder(
            animation: _flicker,
            builder: (context, child) => Opacity(
              opacity: _flicker.value,
              child: GlowText(
                text: glowTitle,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          InputField(
            label: 'Email',
            hint: 'email@domain.com',
            obscure: false,
            controller: _emailController,
            keyBoardType: TextInputType.emailAddress,
            validator: (value) => emailValidator(value),
          ),

          const SizedBox(height: 16),

          InputField(
            label: 'Password',
            hint: '••••••••',
            obscure: true,
            controller: _passwordController,
            keyBoardType: TextInputType.visiblePassword,
            validator: (value) => passwordValidator(value),
          ),

          if (!isLoggedInScreen) ...[
            const SizedBox(height: 16),
            InputField(
              label: 'Confirm Password',
              hint: '••••••••',
              obscure: true,
              controller: _confirmPasswordController,
              keyBoardType: TextInputType.visiblePassword,
              validator: (value) => confirmPasswordValidator(value),
            ),
          ],

          const SizedBox(height: 32),

          Button(
            sweepController: _btnSweepCtrl,
            text: buttonText,
            onTap: handleSubmit,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
