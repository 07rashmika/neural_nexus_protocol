import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/screens/loading_screen.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';

class SplashRouter extends ConsumerStatefulWidget {
  const SplashRouter({super.key});

  @override
  ConsumerState<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends ConsumerState<SplashRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final isLoggedIn = await ApiService.isLoggedIn();

    if (!isLoggedIn) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      return;
    }

    // Has a saved token — show loading screen while fetching profile
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, _, _) =>
            const LoadingScreen(message: 'loading agent...'),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    try {
      final agent = await ApiService.getProfile();
      ref.read(agentProvider.notifier).state = agent;
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (_) {
      // Token expired or invalid — clear it and go to auth
      await ApiService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shown while the routing decision is being made
    return const LoadingScreen(message: 'initialising...');
  }
}
