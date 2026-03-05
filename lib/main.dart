import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/screens/auth_screen.dart';
import 'package:neural_nexus_protocol/widgets/circuit_background.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: NeuralColors.bg, //app theme
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
      home: const AuthScreen(),
    );
  }
}
