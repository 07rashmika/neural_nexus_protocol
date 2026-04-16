import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/digit_key.dart';

class DigitKeypad extends StatelessWidget {
  const DigitKeypad({
    super.key,
    required this.isAnswered,
    required this.correctDigit,
    required this.selectedDigit,
    required this.isCorrectAnswer,
    required this.onDigitTap,
    this.isEnabled = true,
  });

  final bool isAnswered;
  final int? correctDigit;
  final int? selectedDigit;
  final bool? isCorrectAnswer;
  final ValueChanged<int> onDigitTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: 10,
      itemBuilder: (_, i) => DigitKey(
        digit: i,
        isAnswered: isAnswered,
        correctDigit: correctDigit,
        selectedDigit: selectedDigit,
        isCorrectAnswer: isCorrectAnswer,
        isEnabled: isEnabled,
        onTap: () => onDigitTap(i),
      ),
    );
  }
}
