import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/digit_keypad.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/no_shields_dialog.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_answer_feedback.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_hint_chip.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_image_panel.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_timer_bar.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen>
    with SingleTickerProviderStateMixin {
  // ── challenge config ──────────────────────────────────────────────
  static const int _puzzleCount = 5;
  static const int _timerSeconds = 12;

  // ── status ────────────────────────────────────────────────────────
  bool _loadingStatus = true;
  bool _alreadyAttempted = false;
  bool _alreadyCompleted = false;
  int _totalCompleted = 0;
  int _secondsUntilNext = 0;
  Timer? _countdownTimer;

  // ── game state ────────────────────────────────────────────────────
  bool _started = false;

  String? _questionUrl;
  int? _solution;
  int? _carrots;
  bool _loading = false;
  String? _error;

  int _puzzleIndex = 0;
  int _passedCount = 0;
  bool _challengeDone = false;
  bool _challengePassed = false;
  bool _submitting = false;

  int? _selectedAnswer;
  bool? _answerCorrect;
  bool _answered = false;

  int _score = 0;
  int _bonusCarrots = 0;
  int _newTotalCompleted = 0;

  // ── hint ──────────────────────────────────────────────────────────
  bool _hintVisible = false;
  bool _hintUsedThisPuzzle = false;

  // ── timer ─────────────────────────────────────────────────────────
  int _timeLeft = _timerSeconds;
  Timer? _puzzleTimer;

  // ── glow ──────────────────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _glowAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
    _loadStatus();
  }

  @override
  void dispose() {
    _puzzleTimer?.cancel();
    _countdownTimer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── status load ───────────────────────────────────────────────────

  Future<void> _loadStatus() async {
    setState(() => _loadingStatus = true);
    try {
      final data = await ApiService.getDailyChallengeStatus();
      setState(() {
        _alreadyAttempted = data['alreadyAttempted'] as bool;
        _alreadyCompleted = data['alreadyCompleted'] as bool;
        _totalCompleted = data['totalCompleted'] as int;
        _secondsUntilNext = data['secondsUntilNext'] as int;
        _loadingStatus = false;
      });
      if (_alreadyAttempted) _startCountdown();
    } catch (e) {
      setState(() => _loadingStatus = false);
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsUntilNext <= 0) {
        _countdownTimer?.cancel();
        _loadStatus(); // refresh when new challenge unlocks
      } else {
        setState(() => _secondsUntilNext--);
      }
    });
  }

  // ── start challenge ───────────────────────────────────────────────

  Future<void> _onStartChallenge() async {
    // Shield check
    await ref.read(shieldProvider.notifier).sync();
    if (!mounted) return;
    if (ref.read(shieldProvider).isEmpty) {
      _showNoShieldsDialog();
      return;
    }

    try {
      await ApiService.startDailyChallenge();
    } catch (e) {
      // 409 = already started this session but not submitted — allow continue
      if (!e.toString().contains('Already attempted')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
                style: GoogleFonts.spaceMono(fontSize: 10),
              ),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _started = true;
    });
    _fetchPuzzle();
  }

  // ── puzzle ────────────────────────────────────────────────────────

  Future<void> _fetchPuzzle() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedAnswer = null;
      _answerCorrect = null;
      _answered = false;
      _hintVisible = false;
      _hintUsedThisPuzzle = false;
      _timeLeft = _timerSeconds;
    });
    _puzzleTimer?.cancel();
    try {
      final data = await ApiService.fetchHeartPuzzle();
      setState(() {
        _questionUrl = data['question'] as String;
        _solution = data['solution'] as int;
        _carrots = data['carrots'] as int;
        _loading = false;
      });
      _startPuzzleTimer();
    } catch (_) {
      setState(() {
        _error = 'Failed to load puzzle.';
        _loading = false;
      });
    }
  }

  void _startPuzzleTimer() {
    _puzzleTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        t.cancel();
        _onTimeUp();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onTimeUp() {
    if (_answered) return;
    setState(() {
      _answered = true;
      _answerCorrect = false;
    });
    _glowCtrl.forward(from: 0);
    _handleAnswer(correct: false, digit: null);
  }

  void _onAnswer(int digit) {
    if (_answered) return;
    _puzzleTimer?.cancel();
    final correct = digit == _solution;
    setState(() {
      _selectedAnswer = digit;
      _answerCorrect = correct;
      _answered = true;
    });
    _glowCtrl.forward(from: 0);
    _handleAnswer(correct: correct, digit: digit);
  }

  void _handleAnswer({required bool correct, required int? digit}) {
    if (correct) {
      setState(() {
        _score += 10 + _timeLeft;
        _passedCount++;
      });
    } else {
      // Wrong = deduct shield (no lives in daily)
      ref.read(shieldProvider.notifier).deductOne();
      ApiService.submitAnswer(
        round: _puzzleIndex + 1,
        answer: digit ?? -1,
        correct: false,
        timeTaken: _timerSeconds - _timeLeft,
        carrots: 0,
        chain: 0,
        timeLeft: 0,
      );
    }

    // Auto-advance after short delay, or end if last puzzle
    final isLast = _puzzleIndex + 1 >= _puzzleCount;
    if (isLast) {
      Future.delayed(const Duration(milliseconds: 1200), _finishChallenge);
    }
  }

  void _onNextPuzzle() {
    setState(() => _puzzleIndex++);
    _fetchPuzzle();
  }

  Future<void> _finishChallenge() async {
    if (_challengeDone) return;
    _puzzleTimer?.cancel();

    final passed = _passedCount >= _puzzleCount; // all 5 must pass
    setState(() {
      _challengeDone = true;
      _challengePassed = passed;
      _submitting = true;
    });

    try {
      final result = await ApiService.completeDailyChallenge(
        passed: passed,
        puzzlesPassed: _passedCount,
      );
      setState(() {
        _bonusCarrots = result['bonusCarrots'] as int? ?? 0;
        _newTotalCompleted =
            result['totalCompleted'] as int? ?? _totalCompleted;
      });

      // Update agent carrots if passed
      if (passed) {
        final agent = ref.read(agentProvider);
        if (agent != null) {
          ref.read(agentProvider.notifier).state = agent.copyWith(
            intelPoints: agent.intelPoints,
          ); // trigger rebuild
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showNoShieldsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          NoShieldsDialog(onDismiss: () => Navigator.of(context).pop()),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuralColors.bg,
      body: SafeArea(
        child: _loadingStatus
            ? const Center(
                child: CircularProgressIndicator(color: NeuralColors.teal),
              )
            : _alreadyAttempted && !_started
            ? _buildAlreadyAttempted()
            : !_started
            ? _buildLobby()
            : _challengeDone
            ? _buildResult()
            : _buildGame(),
      ),
    );
  }

  // ── lobby ─────────────────────────────────────────────────────────

  Widget _buildLobby() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                Text(
                  'DAILY',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: NeuralColors.tealDim,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CHALLENGE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 22,
                    color: NeuralColors.teal,
                    fontWeight: .w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                InfoRow(
                  label: 'Completed',
                  value: '$_totalCompleted challenges',
                ),
                InfoRow(
                  label: 'Format',
                  value: '5 puzzles · 12s each · no lives',
                ),
                InfoRow(label: 'Reward', value: '🥕 +10 on completion'),
                const SizedBox(height: 8),
                Container(
                  width: .infinity,
                  padding: const .all(12),
                  decoration: BoxDecoration(
                    border: .all(
                      color: const Color(0xFFFF4B6E).withValues(alpha: 0.4),
                    ),
                    color: const Color(0xFFFF4B6E).withValues(alpha: 0.04),
                  ),
                  child: Text(
                    '⚠  ALL 5 MUST PASS  ·  NO SECOND ATTEMPT TODAY',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      color: const Color(0xFFFF4B6E),
                      letterSpacing: 1,
                    ),
                    textAlign: .center,
                  ),
                ),
                const SizedBox(height: 32),
                Button(text: 'Begin', onTap: _onStartChallenge),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ── already attempted ─────────────────────────────────────────────

  Widget _buildAlreadyAttempted() {
    final h = _secondsUntilNext ~/ 3600;
    final m = (_secondsUntilNext % 3600) ~/ 60;
    final s = _secondsUntilNext % 60;
    final countdown =
        '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildBackButton(),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                Icon(
                  _alreadyCompleted
                      ? Icons.verified_rounded
                      : Icons.cancel_outlined,
                  color: _alreadyCompleted
                      ? NeuralColors.teal
                      : const Color(0xFFFF4B6E),
                  size: 52,
                ),
                const SizedBox(height: 16),
                Text(
                  _alreadyCompleted ? 'CHALLENGE COMPLETE' : 'CHALLENGE FAILED',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: .w700,
                    letterSpacing: 3,
                    color: _alreadyCompleted
                        ? NeuralColors.teal
                        : const Color(0xFFFF4B6E),
                  ),
                ),
                const SizedBox(height: 24),
                InfoRow(
                  label: 'Total completed',
                  value: '$_totalCompleted challenges',
                ),
                const SizedBox(height: 32),
                Text(
                  'NEXT CHALLENGE IN',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: NeuralColors.tealDim,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  countdown,
                  style: GoogleFonts.spaceMono(
                    fontSize: 28,
                    color: NeuralColors.teal,
                    fontWeight: .w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ── game ──────────────────────────────────────────────────────────

  Widget _buildGame() {
    final shields = ref.watch(shieldProvider);
    return Padding(
      padding: const .symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildGameHeader(shields),
          const SizedBox(height: 6),
          _buildPuzzleProgressBar(),
          const SizedBox(height: 8),
          _buildTimerBar(),
          const SizedBox(height: 20),
          Expanded(child: _buildPuzzleBody()),
        ],
      ),
    );
  }

  Widget _buildGameHeader(ShieldState shields) {
    return Row(
      children: [
        ShieldCount(count: shields.count, max: ShieldState.max),
        const SizedBox(width: 8),
        Text(
          'DAILY',
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            color: const Color(0xFFFFB347),
            letterSpacing: 3,
            fontWeight: .w700,
          ),
        ),
        const Spacer(),
        Text(
          '$_score',
          style: GoogleFonts.spaceMono(
            fontSize: 13,
            color: NeuralColors.teal,
            fontWeight: .w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPuzzleProgressBar() {
    return Row(
      children: [
        Text(
          'GAUNTLET  ·  BOSS  ·  ${_puzzleIndex + 1}/$_puzzleCount',
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            color: const Color(0xFFFF4B6E),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: List.generate(_puzzleCount, (i) {
              Color c;
              if (i < _puzzleIndex) {
                c = NeuralColors.teal;
              } else if (i == _puzzleIndex) {
                c = _answered
                    ? (_answerCorrect == true
                          ? NeuralColors.teal
                          : const Color(0xFFFF4B6E))
                    : NeuralColors.tealDim;
              } else {
                c = NeuralColors.tealDark;
              }
              return Expanded(
                child: Container(
                  height: 3,
                  margin: .only(right: i < _puzzleCount - 1 ? 3 : 0),
                  color: c,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    return PuzzleTimerBar(timeLeft: _timeLeft, totalSeconds: _timerSeconds);
  }

  Widget _buildPuzzleBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: NeuralColors.tealDim,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'LOADING...',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: NeuralColors.tealBorder,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFFFF4B6E),
              ),
            ),
            const SizedBox(height: 20),
            Button(text: 'Retry', onTap: _fetchPuzzle),
          ],
        ),
      );
    }

    final points = 10 + _timeLeft;

    return Column(
      children: [
        PuzzleImagePanel(imageUrl: _questionUrl!),
        const SizedBox(height: 8),
        if (!_answered)
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                '+$points IP',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: NeuralColors.tealDark,
                ),
              ),
              PuzzleHintChip(
                label: _hintVisible ? '🥕 $_carrots' : '🥕 HINT',
                isAvailable: !_hintUsedThisPuzzle,
                isLoading: false,
                onTap: () => setState(() {
                  _hintVisible = true;
                  _hintUsedThisPuzzle = true;
                }),
              ),
            ],
          ),
        if (_answered)
          PuzzleAnswerFeedback(
            animation: _glowAnim,
            isCorrect: _answerCorrect == true,
            selectedAnswer: _selectedAnswer,
            solution: _solution!,
            pointsEarned: points,
          ),
        const SizedBox(height: 10),
        DigitKeypad(
          isAnswered: _answered,
          correctDigit: _solution,
          selectedDigit: _selectedAnswer,
          isCorrectAnswer: _answerCorrect,
          onDigitTap: _onAnswer,
        ),
        const SizedBox(height: 14),
        if (_answered && _puzzleIndex + 1 < _puzzleCount)
          Button(text: 'Next Puzzle', onTap: _onNextPuzzle),
      ],
    );
  }

  // ── result ────────────────────────────────────────────────────────

  Widget _buildResult() {
    final color = _challengePassed
        ? NeuralColors.teal
        : const Color(0xFFFF4B6E);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _challengePassed
                    ? Icons.verified_rounded
                    : Icons.cancel_outlined,
                color: color,
                size: 52,
              ),
              const SizedBox(height: 20),
              GlowText(
                text: _challengePassed ? 'gauntlet cleared' : 'gauntlet failed',
                fontSize: 20,
                fontWeight: .w600,
                letterSpacing: 2,
              ),
              const SizedBox(height: 6),
              GlowText(
                text: 'daily challenge',
                fontSize: 9,
                letterSpacing: 4,
                fontWeight: .w500,
              ),
              const SizedBox(height: 24),
              InfoRow(
                label: 'Puzzles',
                value: '$_passedCount / $_puzzleCount passed',
              ),
              InfoRow(label: 'Score', value: '$_score pts'),
              if (_challengePassed) ...[
                InfoRow(label: 'Bonus carrots', value: '🥕 +$_bonusCarrots'),
                InfoRow(
                  label: 'Total completed',
                  value: '$_newTotalCompleted challenges',
                ),
              ],
              if (_submitting)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Saving...',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      color: NeuralColors.tealDim,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Button(
                text: 'Back to Home',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ───────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back_ios,
            color: NeuralColors.tealDim,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'BACK',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: NeuralColors.tealDim,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
