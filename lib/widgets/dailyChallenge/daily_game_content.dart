import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_game_header.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_puzzle_progress_bar.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/game_puzzle_body.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_timer_bar.dart';

class DailyGameContent extends StatelessWidget {
  const DailyGameContent({
    super.key,
    required this.shields,
    required this.score,
    required this.puzzleIndex,
    required this.puzzleCount,
    required this.answered,
    required this.answerCorrect,
    required this.isLoading,
    required this.error,
    required this.questionUrl,
    required this.solution,
    required this.selectedAnswer,
    required this.timeLeft,
    required this.hintVisible,
    required this.hintValue,
    required this.hintUsedThisPuzzle,
    required this.animation,
    required this.onRetry,
    required this.onUseHint,
    required this.onAnswer,
    required this.onNextPuzzle,
  });

  final ShieldState shields;
  final int score;
  final int puzzleIndex;
  final int puzzleCount;
  final bool answered;
  final bool? answerCorrect;
  final bool isLoading;
  final String? error;
  final String? questionUrl;
  final int? solution;
  final int? selectedAnswer;
  final int timeLeft;
  final bool hintVisible;
  final int? hintValue;
  final bool hintUsedThisPuzzle;
  final Animation<double> animation;
  final VoidCallback onRetry;
  final VoidCallback onUseHint;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNextPuzzle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailyGameHeader(shields: shields, score: score),
          const SizedBox(height: 6),
          DailyPuzzleProgressBar(
            puzzleIndex: puzzleIndex,
            puzzleCount: puzzleCount,
            answered: answered,
            answerCorrect: answerCorrect,
          ),
          const SizedBox(height: 8),
          PuzzleTimerBar(timeLeft: timeLeft, totalSeconds: 12),
          const SizedBox(height: 20),
          Expanded(
            child: GamePuzzleBody(
              isLoading: isLoading,
              error: error,
              questionUrl: questionUrl,
              answered: answered,
              answerCorrect: answerCorrect,
              selectedAnswer: selectedAnswer,
              solution: solution,
              timeLeft: timeLeft,
              chainMultiplier: 1,
              hintVisible: hintVisible,
              hintValue: hintValue,
              carrotsRemaining: 1,
              hintUsedThisPuzzle: hintUsedThisPuzzle,
              usingHint: false,
              paused: false,
              showChainBreakText: false,
              showCorrectAnswerOnTimeout: false,
              isLastPuzzle: puzzleIndex + 1 >= puzzleCount,
              nodeDone: false,
              animation: animation,
              onRetry: onRetry,
              onUseHint: onUseHint,
              onAnswer: onAnswer,
              onNextPuzzle: onNextPuzzle,
            ),
          ),
        ],
      ),
    );
  }
}
