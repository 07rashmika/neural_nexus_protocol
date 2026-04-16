import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';

import '../../providers/login_screen_provider.dart';

class SwapAuth extends ConsumerWidget {
  const SwapAuth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedInScreen = ref.watch(isLoginScreenProvider);

    return Row(
      crossAxisAlignment: .start,
      children: [
        Text(
          isLoggedInScreen ? 'New Agent?' : 'Already an Agent?',
          style: GoogleFonts.spaceMono(
            color: NeuralColors.textMain,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => ref.read(isLoginScreenProvider.notifier).state =
              !isLoggedInScreen,
          child: Column(
            children: [
              Text(
                isLoggedInScreen ? 'Register' : 'Login',
                style: GoogleFonts.spaceMono(
                  color: NeuralColors.textMain,
                  fontSize: 14,
                ),
              ),
              Container(
                margin: const .only(top: 2),
                height: 3,
                width: isLoggedInScreen ? 70 : 45,
                color: NeuralColors.tealDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
