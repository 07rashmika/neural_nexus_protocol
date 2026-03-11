import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/no_shields_dialog.dart';
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
  bool _shieldCheckDone = false;

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
      _shieldCheckDone = true;
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
              mainAxisSize: MainAxisSize.min,
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                _statRow('Completed', '$_totalCompleted challenges'),
                _statRow('Format', '5 puzzles · 12s each · no lives'),
                _statRow('Reward', '🥕 +10 on completion'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
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
                    textAlign: TextAlign.center,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: _alreadyCompleted
                        ? NeuralColors.teal
                        : const Color(0xFFFF4B6E),
                  ),
                ),
                const SizedBox(height: 24),
                _statRow('Total completed', '$_totalCompleted challenges'),
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
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '$_score',
          style: GoogleFonts.spaceMono(
            fontSize: 13,
            color: NeuralColors.teal,
            fontWeight: FontWeight.w700,
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
              if (i < _puzzleIndex)
                c = NeuralColors.teal;
              else if (i == _puzzleIndex)
                c = _answered
                    ? (_answerCorrect == true
                          ? NeuralColors.teal
                          : const Color(0xFFFF4B6E))
                    : NeuralColors.tealDim;
              else
                c = NeuralColors.tealDark;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < _puzzleCount - 1 ? 3 : 0),
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
    final fraction = _timeLeft / _timerSeconds;
    final barColor = fraction > 0.5
        ? NeuralColors.teal
        : fraction > 0.25
        ? const Color(0xFFFFB347)
        : const Color(0xFFFF4B6E);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TIME',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: NeuralColors.tealBorder,
                letterSpacing: 3,
              ),
            ),
            Text(
              '${_timeLeft}s',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: barColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRect(
          child: Container(
            height: 3,
            width: double.infinity,
            color: NeuralColors.tealDark,
            child: AnimatedFractionallySizedBox(
              widthFactor: fraction,
              duration: const Duration(milliseconds: 800),
              curve: Curves.linear,
              alignment: Alignment.centerLeft,
              child: Container(color: barColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPuzzleBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: NeuralColors.tealDark),
              color: NeuralColors.teal.withValues(alpha: 0.02),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.network(
              _questionUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, prog) => prog == null
                  ? child
                  : Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: NeuralColors.tealDim,
                      ),
                    ),
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  'IMAGE ERROR',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: const Color(0xFFFF4B6E),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Hint row
        if (!_answered)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+${10 + _timeLeft} IP',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: NeuralColors.tealDark,
                ),
              ),
              GestureDetector(
                onTap: (!_hintUsedThisPuzzle)
                    ? () => setState(() {
                        _hintVisible = true;
                        _hintUsedThisPuzzle = true;
                      })
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: !_hintUsedThisPuzzle
                          ? const Color(0xFFFFB347)
                          : NeuralColors.tealDark,
                    ),
                    color: !_hintUsedThisPuzzle
                        ? const Color(0xFFFFB347).withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                  child: Text(
                    _hintVisible ? '🥕 $_carrots' : '🥕 HINT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: !_hintUsedThisPuzzle
                          ? const Color(0xFFFFB347)
                          : NeuralColors.tealDark,
                    ),
                  ),
                ),
              ),
            ],
          ),

        if (_answered)
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, _) {
              final color = _answerCorrect == true
                  ? NeuralColors.teal
                  : const Color(0xFFFF4B6E);
              return Text(
                _answerCorrect == true
                    ? '✓  +${10 + _timeLeft} IP'
                    : _selectedAnswer == null
                    ? '✗  TIME\'S UP  (ans: $_solution)'
                    : '✗  WRONG  (ans: $_solution)',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: color,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: _glowAnim.value * 0.8),
                      blurRadius: 12 * _glowAnim.value,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              );
            },
          ),

        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
          ),
          itemCount: 10,
          itemBuilder: (_, i) => _buildDigitKey(i),
        ),

        const SizedBox(height: 14),

        if (_answered && _puzzleIndex + 1 < _puzzleCount)
          Button(text: 'Next Puzzle', onTap: _onNextPuzzle),
      ],
    );
  }

  Widget _buildDigitKey(int digit) {
    Color border = NeuralColors.tealDark;
    Color bg = Colors.transparent;
    Color text = NeuralColors.textMain;
    if (_answered) {
      if (digit == _solution) {
        border = NeuralColors.teal;
        bg = NeuralColors.teal.withValues(alpha: 0.12);
        text = NeuralColors.teal;
      } else if (digit == _selectedAnswer && !(_answerCorrect ?? true)) {
        border = const Color(0xFFFF4B6E);
        bg = const Color(0xFFFF4B6E).withValues(alpha: 0.1);
        text = const Color(0xFFFF4B6E);
      } else {
        border = NeuralColors.tealDark.withValues(alpha: 0.4);
        text = NeuralColors.tealBorder;
      }
    }
    return GestureDetector(
      onTap: _answered ? null : () => _onAnswer(digit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          color: bg,
        ),
        child: Center(
          child: Text(
            '$digit',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ),
      ),
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
              Text(
                _challengePassed ? 'GAUNTLET CLEARED' : 'GAUNTLET FAILED',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'DAILY CHALLENGE',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: const Color(0xFFFFB347),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              _statRow('Puzzles', '$_passedCount / $_puzzleCount passed'),
              _statRow('Score', '$_score pts'),
              if (_challengePassed) ...[
                _statRow('Bonus carrots', '🥕 +$_bonusCarrots'),
                _statRow('Total completed', '$_newTotalCompleted challenges'),
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

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: NeuralColors.tealDim,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: NeuralColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
