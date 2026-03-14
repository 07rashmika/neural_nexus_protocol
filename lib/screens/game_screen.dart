import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/digit_keypad.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/no_shields_dialog.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/pause_dialog.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_answer_feedback.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_hint_chip.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_image_panel.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_timer_bar.dart';
import 'package:neural_nexus_protocol/widgets/info_row.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.node,
    required this.sectorCode,
    required this.carrotsRemaining,
  });

  final NodeModel node;
  final String sectorCode;
  final int carrotsRemaining;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  String? _questionUrl;
  int? _solution;
  int? _carrots;
  bool _loading = true;
  String? _error;

  int _puzzleIndex = 0;
  int _passedCount = 0;
  int _livesLeft = 0;
  bool _nodeDone = false;
  bool _nodePassed = false;
  bool _completing = false;

  int? _selectedAnswer;
  bool? _answerCorrect;
  bool _answered = false;

  int _score = 0;

  bool _hintVisible = false;
  bool _hintUsedThisPuzzle = false;
  bool _usingHint = false;
  late int _carrotsRemaining;

  bool _levelUp = false;
  bool _paused = false;

  late int _timerSeconds;
  int _timeLeft = 30;
  Timer? _timer;

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  bool _shieldCheckDone = false;

  int get _chainMultiplier =>
      ref.read(agentProvider)?.chainMultiplier.clamp(1, 5) ?? 1;

  @override
  void initState() {
    super.initState();
    _timerSeconds = widget.node.timerSeconds;
    _timeLeft = _timerSeconds;
    _livesLeft = widget.node.lives;
    _carrotsRemaining = widget.carrotsRemaining;
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _glowAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initGame());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Pause ─────────────────────────────────────────────────────────

  void _onPause() {
    if (_answered || _nodeDone || _loading) return;
    _timer?.cancel();
    setState(() => _paused = true);
    _showPauseDialog();
  }

  void _resumeGame() {
    setState(() => _paused = false);
    _startTimer();
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // we handle blur ourselves
      builder: (_) => PauseDialog(
        node: widget.node,
        puzzleIndex: _puzzleIndex,
        score: _score,
        timeLeft: _timeLeft,
        carrotsRemaining: _carrotsRemaining,
        onResume: () {
          Navigator.of(context).pop();
          _resumeGame();
        },
        onQuit: () {
          Navigator.of(context).pop(); // pop dialog
          _backToNodes(false);
        },
      ),
    );
  }

  // ── Init / fetch ──────────────────────────────────────────────────

  Future<void> _initGame() async {
    await ref.read(shieldProvider.notifier).sync();
    if (!mounted) return;
    setState(() => _shieldCheckDone = true);
    if (ref.read(shieldProvider).isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showNoShieldsDialog(),
      );
      return;
    }
    _fetchPuzzle();
  }

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
      _levelUp = false;
      _paused = false;
    });
    _timer?.cancel();
    try {
      final data = await ApiService.fetchHeartPuzzle();
      setState(() {
        _questionUrl = data['question'] as String;
        _solution = data['solution'] as int;
        _carrots = data['carrots'] as int;
        _loading = false;
      });
      _startTimer();
    } catch (_) {
      setState(() {
        _error = 'Failed to load puzzle.';
        _loading = false;
      });
    }
  }

  Future<void> _onUseHint() async {
    if (_carrotsRemaining <= 0 || _hintUsedThisPuzzle || _usingHint) return;
    setState(() => _usingHint = true);
    try {
      final result = await ApiService.useHint(sectorCode: widget.sectorCode);
      setState(() {
        _carrotsRemaining = result['carrotsRemaining'] as int;
        _hintVisible = true;
        _hintUsedThisPuzzle = true;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _usingHint = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_paused) return;
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
    _handleWrongAnswer(digit: null);
  }

  void _onAnswer(int digit) {
    if (_answered || _paused) return;
    _timer?.cancel();
    final correct = digit == _solution;
    setState(() {
      _selectedAnswer = digit;
      _answerCorrect = correct;
      _answered = true;
    });
    _glowCtrl.forward(from: 0);
    if (correct) {
      _handleCorrectAnswer(digit);
    } else {
      _handleWrongAnswer(digit: digit);
    }
  }

  Future<void> _handleCorrectAnswer(int digit) async {
    final multiplier = _chainMultiplier;
    setState(() {
      _score += (10 + _timeLeft) * multiplier;
      _passedCount++;
    });
    final result = await ApiService.submitAnswer(
      round: _puzzleIndex + 1,
      answer: digit,
      correct: true,
      timeTaken: _timerSeconds - _timeLeft,
      carrots: _carrots ?? 0,
      chain: multiplier - 1,
      timeLeft: _timeLeft,
    );
    if (!mounted) return;
    if (result != null) _applyProgressionResult(result);
    _advanceNode(wasCorrect: true);
  }

  Future<void> _onNodeFailed() async {
    try {
      await ApiService.failNode();
      final agent = ref.read(agentProvider);
      if (agent != null) {
        ref.read(agentProvider.notifier).state = agent.copyWith(streak: 0);
      }
    } catch (_) {}
  }

  Future<void> _handleWrongAnswer({required int? digit}) async {
    final agent = ref.read(agentProvider);
    if (agent != null) {
      ref.read(agentProvider.notifier).state = agent.copyWith(
        chainMultiplier: 1,
      );
    }
    if (widget.node.lives > 0) {
      setState(() => _livesLeft = (_livesLeft - 1).clamp(0, widget.node.lives));
    }
    ref.read(shieldProvider.notifier).deductOne();
    final result = await ApiService.submitAnswer(
      round: _puzzleIndex + 1,
      answer: digit ?? -1,
      correct: false,
      timeTaken: _timerSeconds - _timeLeft,
      carrots: 0,
      chain: 0,
      timeLeft: 0,
    );
    if (!mounted) return;
    if (result != null) {
      if (result['shieldData'] != null) {
        ref
            .read(shieldProvider.notifier)
            .applyBackendResult(result['shieldData'] as Map<String, dynamic>);
      }
      _applyProgressionResult(result);
    }
    _advanceNode(wasCorrect: false);
  }

  void _advanceNode({required bool wasCorrect}) {
    if (_nodeDone) return;
    final failedSoFar = (_puzzleIndex + 1) - _passedCount;
    final outOfLives = failedSoFar > widget.node.lives;
    final lastPuzzle = _puzzleIndex + 1 >= widget.node.puzzleCount;
    if (outOfLives) {
      setState(() {
        _nodeDone = true;
        _nodePassed = false;
      });
      _onNodeFailed();
    } else if (lastPuzzle) {
      final passed = failedSoFar <= widget.node.lives;
      setState(() {
        _nodeDone = true;
        _nodePassed = passed;
      });
      if (passed) {
        _completeNodeOnBackend();
      } else {
        _onNodeFailed();
      }
    }
  }

  Future<void> _completeNodeOnBackend() async {
    setState(() => _completing = true);
    try {
      final result = await ApiService.completeNode(widget.node.id);
      if (!mounted) return;
      final agent = ref.read(agentProvider);
      if (agent != null) {
        final newIntel =
            (result['newIntelTotal'] as num?)?.toDouble() ?? agent.intelPoints;
        final newLevel = result['newLevel'] as int? ?? agent.level;
        final newPosition = result['newPosition'] as String? ?? agent.position;
        final newChainMult = (agent.chainMultiplier + 1).clamp(1, 5);
        final newStreak = result['newStreak'] as int? ?? agent.streak;
        if (newLevel > agent.level) setState(() => _levelUp = true);
        ref.read(agentProvider.notifier).state = agent.copyWith(
          intelPoints: newIntel,
          level: newLevel,
          position: newPosition,
          chainMultiplier: newChainMult,
          streak: newStreak,
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  void _onNextPuzzle() {
    if (_nodeDone) return;
    setState(() => _puzzleIndex++);
    _fetchPuzzle();
  }

  void _applyProgressionResult(Map<String, dynamic> r) {
    final agent = ref.read(agentProvider);
    if (agent == null) return;
    final newIntel =
        (r['newIntelTotal'] as num?)?.toDouble() ?? agent.intelPoints;
    final newLevel = r['newLevel'] as int? ?? agent.level;
    final newPosition = r['newPosition'] as String? ?? agent.position;
    final newStreak = r['newStreak'] as int? ?? agent.streak;
    if (r['levelUp'] as bool? ?? false) setState(() => _levelUp = true);
    ref.read(agentProvider.notifier).state = agent.copyWith(
      intelPoints: newIntel,
      level: newLevel,
      position: newPosition,
      streak: newStreak,
    );
  }

  void _showNoShieldsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NoShieldsDialog(
        onDismiss: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(false);
        },
      ),
    );
  }

  void _backToNodes(bool passed) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop(passed);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final shields = ref.watch(shieldProvider);
    return Scaffold(
      backgroundColor: NeuralColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const .symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              _buildHeader(shields),
              const SizedBox(height: 6),
              _buildNodeProgressBar(),
              const SizedBox(height: 8),
              _buildTimerBar(),
              const SizedBox(height: 20),
              Expanded(
                child: !_shieldCheckDone
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: NeuralColors.tealDim,
                        ),
                      )
                    : _nodeDone
                    ? _buildNodeResult()
                    : _buildPuzzleBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ShieldState shields) {
    final agent = ref.watch(agentProvider);
    return Row(
      children: [
        ShieldCount(count: shields.count, max: ShieldState.max),
        const SizedBox(width: 10),
        if (agent != null)
          Text(
            '${agent.intelPoints.toStringAsFixed(0)} IP',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: NeuralColors.tealDim,
              letterSpacing: 1,
            ),
          ),
        const Spacer(),
        if (widget.node.lives > 0) ...[
          Row(
            children: List.generate(widget.node.lives + 1, (i) {
              final spent = i > _livesLeft;
              return Padding(
                padding: const .only(right: 4),
                child: Icon(
                  spent ? Icons.favorite_border : Icons.favorite,
                  color: spent
                      ? NeuralColors.tealDark
                      : const Color(0xFFFF4B6E),
                  size: 14,
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          '$_score',
          style: GoogleFonts.spaceMono(
            fontSize: 13,
            color: NeuralColors.teal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),

        // ── Pause button ───────────────────────────────────────────
        if (!_nodeDone)
          GestureDetector(
            onTap: _onPause,
            child: Container(
              padding: const .all(6),
              decoration: BoxDecoration(
                border: Border.all(color: NeuralColors.tealDark),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.pause,
                color: NeuralColors.tealDim,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeProgressBar() {
    final total = widget.node.puzzleCount;
    final current = _puzzleIndex;
    final diffColor = _difficultyColor(widget.node.difficulty);
    return Row(
      children: [
        Text(
          'NODE ${widget.node.nodeNumber}  ·  ${widget.node.difficultyLabel.toUpperCase()}  ·  ${_puzzleIndex + 1}/$total',
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            color: diffColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: List.generate(total, (i) {
              Color c;
              if (i < current) {
                c = NeuralColors.teal;
              } else if (i == current) {
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
                  margin: .only(right: i < total - 1 ? 3 : 0),
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
            const SizedBox(
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
          mainAxisSize: .min,
          children: [
            Text(
              _error!,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFFFF4B6E),
              ),
              textAlign: .center,
            ),
            const SizedBox(height: 20),
            Button(text: 'Retry', onTap: _fetchPuzzle),
          ],
        ),
      );
    }

    final mult = _chainMultiplier;
    final points = (10 + _timeLeft) * mult;

    return Column(
      children: [
        PuzzleImagePanel(imageUrl: _questionUrl!),
        const SizedBox(height: 8),
        if (!_answered)
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                '+$points IP  x$mult',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: NeuralColors.tealDark,
                ),
              ),
              PuzzleHintChip(
                label: _hintVisible
                    ? 'HINT: $_carrots'
                    : '🥕 x$_carrotsRemaining  HINT',
                isAvailable: _carrotsRemaining > 0 && !_hintUsedThisPuzzle,
                isLoading: _usingHint,
                onTap: _onUseHint,
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
            chainMultiplier: mult,
            showChainBreakText: true,
            showCorrectAnswerOnTimeout: false,
          ),
        const SizedBox(height: 10),
        DigitKeypad(
          isAnswered: _answered,
          correctDigit: _solution,
          selectedDigit: _selectedAnswer,
          isCorrectAnswer: _answerCorrect,
          isEnabled: !_paused,
          onDigitTap: _onAnswer,
        ),
        const SizedBox(height: 14),
        if (_answered && !_nodeDone)
          Button(
            text: _puzzleIndex + 1 >= widget.node.puzzleCount
                ? 'Finish'
                : 'Next Puzzle',
            onTap: _onNextPuzzle,
          ),
      ],
    );
  }

  Widget _buildNodeResult() {
    final passed = _nodePassed;
    final color = passed ? NeuralColors.teal : const Color(0xFFFF4B6E);
    final agent = ref.watch(agentProvider);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(
              passed ? Icons.verified_rounded : Icons.cancel_outlined,
              color: color,
              size: 52,
            ),
            const SizedBox(height: 20),
            GlowText(
              text: passed
                  ? 'NODE ${widget.node.nodeNumber} CLEARED'
                  : 'NODE ${widget.node.nodeNumber} FAILED',
              fontSize: 18,
              fontWeight: .w600,
              letterSpacing: 2,
            ),
            const SizedBox(height: 6),
            Text(
              widget.node.difficultyLabel.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: _difficultyColor(widget.node.difficulty),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            InfoRow(
              label: 'Puzzles',
              value: '$_passedCount / ${widget.node.puzzleCount} passed',
            ),
            InfoRow(label: 'Score', value: '$_score pts'),
            if (agent != null)
              InfoRow(
                label: 'Intel',
                value: '${agent.intelPoints.toStringAsFixed(0)} IP',
              ),
            if (agent != null)
              InfoRow(label: 'Chain', value: 'x${agent.chainMultiplier}'),
            InfoRow(label: 'Hints left', value: '🥕 x$_carrotsRemaining'),
            if (passed && _completing)
              Padding(
                padding: const .only(top: 8),
                child: Text(
                  'Saving...',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: NeuralColors.tealDim,
                  ),
                ),
              ),
            if (_levelUp)
              Padding(
                padding: const .only(top: 8),
                child: Text(
                  '▲ LEVEL UP!',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: const Color(0xFFFFB347),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            if (passed)
              Button(text: 'Back to Nodes', onTap: () => _backToNodes(true))
            else ...[
              Button(text: 'Try Again', onTap: () => _backToNodes(false)),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => _backToNodes(false),
                child: Text(
                  'Back',
                  style: GoogleFonts.spaceMono(
                    fontSize: 15,
                    color: NeuralColors.tealDim,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(NodeDifficulty d) => switch (d) {
    NodeDifficulty.standard => Colors.greenAccent,
    NodeDifficulty.secured => NeuralColors.teal,
    NodeDifficulty.critical => const Color(0xFFFFB347),
    NodeDifficulty.boss => const Color(0xFFFF4B6E),
  };
}
