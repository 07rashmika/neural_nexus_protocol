import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/digit_keypad.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_answer_feedback.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_hint_chip.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_image_panel.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_loading_view.dart';

class GamePuzzleBody extends StatelessWidget {
  const GamePuzzleBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.questionUrl,
    required this.answered,
    required this.answerCorrect,
    required this.selectedAnswer,
    required this.solution,
    required this.timeLeft,
    required this.chainMultiplier,
    required this.hintVisible,
    required this.hintValue,
    required this.carrotsRemaining,
    required this.hintUsedThisPuzzle,
    required this.usingHint,
    required this.paused,
    required this.showChainBreakText,
    required this.showCorrectAnswerOnTimeout,
    required this.isLastPuzzle,
    required this.nodeDone,
    required this.animation,
    required this.onRetry,
    required this.onUseHint,
    required this.onAnswer,
    required this.onNextPuzzle,
  });

  final bool isLoading;
  final String? error;
  final String? questionUrl;
  final bool answered;
  final bool? answerCorrect;
  final int? selectedAnswer;
  final int? solution;
  final int timeLeft;
  final int chainMultiplier;
  final bool hintVisible;
  final int? hintValue;
  final int carrotsRemaining;
  final bool hintUsedThisPuzzle;
  final bool usingHint;
  final bool paused;
  final bool showChainBreakText;
  final bool showCorrectAnswerOnTimeout;
  final bool isLastPuzzle;
  final bool nodeDone;
  final Animation<double> animation;
  final VoidCallback onRetry;
  final VoidCallback onUseHint;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNextPuzzle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const PuzzleLoadingView();
    }
    if (error != null) {
      return PuzzleErrorView(message: error!, onRetry: onRetry);
    }

    final points = (10 + timeLeft) * chainMultiplier;

    return Column(
      children: [
        PuzzleImagePanel(imageUrl: questionUrl!),
        const SizedBox(height: 8),
        if (!answered)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+$points IP  x$chainMultiplier',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: NeuralColors.tealDark,
                ),
              ),
              PuzzleHintChip(
                label: hintVisible
                    ? 'HINT: $hintValue'
                    : '🥕 x$carrotsRemaining  HINT',
                isAvailable: carrotsRemaining > 0 && !hintUsedThisPuzzle,
                isLoading: usingHint,
                onTap: onUseHint,
              ),
            ],
          ),
        if (answered)
          PuzzleAnswerFeedback(
            animation: animation,
            isCorrect: answerCorrect == true,
            selectedAnswer: selectedAnswer,
            solution: solution!,
            pointsEarned: points,
            chainMultiplier: chainMultiplier,
            showChainBreakText: showChainBreakText,
            showCorrectAnswerOnTimeout: showCorrectAnswerOnTimeout,
          ),
        const SizedBox(height: 10),
        DigitKeypad(
          isAnswered: answered,
          correctDigit: solution,
          selectedDigit: selectedAnswer,
          isCorrectAnswer: answerCorrect,
          isEnabled: !paused,
          onDigitTap: onAnswer,
        ),
        const SizedBox(height: 14),
        if (answered && !nodeDone)
          Button(
            text: isLastPuzzle ? 'Finish' : 'Next Puzzle',
            onTap: onNextPuzzle,
          ),
      ],
    );
  }
}
