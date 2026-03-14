import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/screens/auth_screen.dart';
import 'package:neural_nexus_protocol/screens/home_screen.dart';
import 'package:neural_nexus_protocol/widgets/circuit_background.dart';
import 'package:neural_nexus_protocol/widgets/common/audio_app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: AudioAppWrapper(child: MyApp())));
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
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
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