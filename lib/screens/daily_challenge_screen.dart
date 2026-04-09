import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_attempted_view.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_game_content.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_lobby_view.dart';
import 'package:neural_nexus_protocol/widgets/dailyChallenge/daily_result_view.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/no_shields_dialog.dart';

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
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
    return DailyLobbyView(
      totalCompleted: _totalCompleted,
      onBack: () => Navigator.of(context).pop(),
      onBegin: _onStartChallenge,
    );
  }

  Widget _buildAlreadyAttempted() {
    return DailyAttemptedView(
      alreadyCompleted: _alreadyCompleted,
      totalCompleted: _totalCompleted,
      secondsUntilNext: _secondsUntilNext,
      onBack: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildGame() {
    final shields = ref.watch(shieldProvider);
    return DailyGameContent(
      shields: shields,
      score: _score,
      puzzleIndex: _puzzleIndex,
      puzzleCount: _puzzleCount,
      answered: _answered,
      answerCorrect: _answerCorrect,
      isLoading: _loading,
      error: _error,
      questionUrl: _questionUrl,
      solution: _solution,
      selectedAnswer: _selectedAnswer,
      timeLeft: _timeLeft,
      hintVisible: _hintVisible,
      hintValue: _carrots,
      hintUsedThisPuzzle: _hintUsedThisPuzzle,
      animation: _glowAnim,
      onRetry: _fetchPuzzle,
      onUseHint: () => setState(() {
        _hintVisible = true;
        _hintUsedThisPuzzle = true;
      }),
      onAnswer: _onAnswer,
      onNextPuzzle: _onNextPuzzle,
    );
  }

  Widget _buildResult() {
    return DailyResultView(
      challengePassed: _challengePassed,
      passedCount: _passedCount,
      puzzleCount: _puzzleCount,
      score: _score,
      bonusCarrots: _bonusCarrots,
      newTotalCompleted: _newTotalCompleted,
      submitting: _submitting,
      onBackHome: () => Navigator.of(context).pop(),
    );
  }
}
