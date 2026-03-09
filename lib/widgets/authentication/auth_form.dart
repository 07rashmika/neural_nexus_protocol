import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/login_screen_provider.dart';
import '../common/button.dart';
import '../common/glow_text.dart';
import 'input_field.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key, required this.onSubmit});

  final Future<void> Function({
    required String email,
    required String password,
    String? confirmPassword,
    String? username,
  })
  onSubmit;

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm>
    with TickerProviderStateMixin {
  late AnimationController _flickerCtrl;
  late Animation<double> _flicker;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _apiError;

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
  }

  @override
  void dispose() {
    _flickerCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Clears all fields and resets validation when switching between login/register
  void _clearAll() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _usernameController.clear();
    _formKey.currentState?.reset();
    setState(() => _apiError = null);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to screen changes and clear form whenever mode switches
    ref.listen(isLoginScreenProvider, (_, _) => _clearAll());

    final isLoginScreen = ref.watch(isLoginScreenProvider);

    Future<void> handleSubmit() async {
      setState(() => _apiError = null);

      print('=== SUBMIT PRESSED ===');
      print('isLoginScreen: $isLoginScreen');
      print('email: ${_emailController.text}');
      print('password length: ${_passwordController.text.length}');
      print('username: ${_usernameController.text}');
      print('confirmPassword: ${_confirmPasswordController.text}');

      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      try {
        await widget.onSubmit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: isLoginScreen
              ? null
              : _confirmPasswordController.text,
          username: isLoginScreen ? null : _usernameController.text.trim(),
        );
        // ← navigation removed from here, auth_screen.dart handles it
      } on Exception catch (e) {
        setState(
          () => _apiError = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }

    final glowTitle = isLoginScreen ? 'WELCOME BACK AGENT!' : 'WELCOME AGENT!';
    final buttonText = isLoginScreen ? 'LOGIN' : 'REGISTER';

    String? emailValidator(String? value) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return 'Email is required';
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
        return 'Enter a valid email';
      }
      return null;
    }

    String? passwordValidator(String? value) {
      final v = value ?? '';
      if (v.isEmpty) return 'Password is required';
      if (v.length < 6) return 'Use at least 6 characters';
      return null;
    }

    String? confirmPasswordValidator(String? value) {
      if (isLoginScreen) return null; // skip entirely on login
      if ((value ?? '').isEmpty) return 'Confirm your password';
      if (value != _passwordController.text) return 'Passwords do not match';
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
                fontWeight: .w900,
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
            keyBoardType: .emailAddress,
            validator: emailValidator,
          ),

          const SizedBox(height: 16),

          InputField(
            label: 'Password',
            hint: '••••••••',
            obscure: true,
            controller: _passwordController,
            keyBoardType: .visiblePassword,
            validator: passwordValidator,
          ),

          if (!isLoginScreen) ...[
            const SizedBox(height: 16),
            InputField(
              label: 'Confirm Password',
              hint: '••••••••',
              obscure: true,
              controller: _confirmPasswordController,
              keyBoardType: .visiblePassword,
              validator: confirmPasswordValidator,
            ),
          ],

          if (_apiError != null) ...[
            const SizedBox(height: 12),
            Text(
              _apiError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: .center,
            ),
          ],

          const SizedBox(height: 32),

          Button(text: buttonText, onTap: handleSubmit),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
