import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/screens/auth_screen.dart';
import 'package:neural_nexus_protocol/screens/home_screen.dart';
import 'package:neural_nexus_protocol/screens/profile_setup_screen.dart';
// import 'package:neural_nexus_protocol/services/sound_service.dart';
import 'package:neural_nexus_protocol/widgets/circuit_background.dart';
import 'package:neural_nexus_protocol/widgets/splash_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // SoundService.instance.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: NeuralColors.bg,
        colorScheme: ColorScheme.dark(
          primary: NeuralColors.teal,
          secondary: NeuralColors.tealDim,
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            const Positioned.fill(child: CircuitBackground()),
            Positioned.fill(child: child!),
          ],
        );
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashRouter(),
        '/auth': (context) => const AuthScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => Consumer(
          builder: (context, ref, _) {
            final agent = ref.watch(agentProvider);
            if (agent == null) return const AuthScreen();
            return HomeScreen(agent: agent);
          },
        ),
      },
    );
  }
}
