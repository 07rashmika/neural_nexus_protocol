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
import 'package:neural_nexus_protocol/widgets/gameScreen/no_shields_dialog.dart';
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
  int _totalCarrots = 0;

  // hint state
  bool _hintVisible = false;
  bool _hintUsedThisPuzzle = false;
  bool _usingHint = false;
  late int _carrotsRemaining;

  bool _levelUp = false;

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
      // silent
    } finally {
      if (mounted) setState(() => _usingHint = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    if (_answered) return;
    _timer?.cancel();
    final correct = digit == _solution;
    setState(() {
      _selectedAnswer = digit;
      _answerCorrect = correct;
      _answered = true;
    });
    _glowCtrl.forward(from: 0);
    if (correct)
      _handleCorrectAnswer(digit);
    else
      _handleWrongAnswer(digit: digit);
  }

  Future<void> _handleCorrectAnswer(int digit) async {
    final multiplier = _chainMultiplier;
    setState(() {
      _score += (10 + _timeLeft) * multiplier;
      _totalCarrots += _carrots ?? 0;
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
      // Reset streak in agentProvider
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
      if (passed)
        _completeNodeOnBackend();
      else
        _onNodeFailed();
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

  @override
  Widget build(BuildContext context) {
    final shields = ref.watch(shieldProvider);
    return Scaffold(
      backgroundColor: NeuralColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(shields),
              const SizedBox(height: 6),
              _buildNodeProgressBar(),
              const SizedBox(height: 8),
              _buildTimerBar(),
              const SizedBox(height: 20),
              Expanded(
                child: !_shieldCheckDone
                    ? Center(
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
                padding: const EdgeInsets.only(right: 4),
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
                  margin: EdgeInsets.only(right: i < total - 1 ? 3 : 0),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Button(text: 'Retry', onTap: _fetchPuzzle),
          ],
        ),
      );
    }

    final mult = _chainMultiplier;

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
              loadingBuilder: (_, child, progress) => progress == null
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
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Hint / intel row ─────────────────────────────────────────
        if (!_answered)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+${(10 + _timeLeft) * mult} IP  x$mult',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: NeuralColors.tealDark,
                ),
              ),
              GestureDetector(
                onTap:
                    (_carrotsRemaining > 0 &&
                        !_hintUsedThisPuzzle &&
                        !_usingHint)
                    ? _onUseHint
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (_carrotsRemaining > 0 && !_hintUsedThisPuzzle)
                          ? const Color(0xFFFFB347)
                          : NeuralColors.tealDark,
                    ),
                    color: (_carrotsRemaining > 0 && !_hintUsedThisPuzzle)
                        ? const Color(0xFFFFB347).withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                  child: _usingHint
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFFFFB347),
                          ),
                        )
                      : Text(
                          _hintVisible
                              ? 'HINT: $_carrots'
                              : '🥕 x$_carrotsRemaining  HINT',
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            letterSpacing: 1,
                            color:
                                (_carrotsRemaining > 0 && !_hintUsedThisPuzzle)
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
              final intel = _answerCorrect == true
                  ? (10 + _timeLeft) * mult
                  : 0;
              final color = _answerCorrect == true
                  ? NeuralColors.teal
                  : const Color(0xFFFF4B6E);
              return Column(
                children: [
                  Text(
                    _answerCorrect == true
                        ? '✓  +$intel IP  x$mult'
                        : _selectedAnswer == null
                        ? '✗  TIME\'S UP  —  chain broken'
                        : '✗  WRONG  (ans: $_solution)  —  chain broken',
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
                  ),
                  if (_answerCorrect == true && mult >= 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        mult >= 5 ? '🔥 MAX CHAIN x$mult' : '⚡ CHAIN x$mult',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          color: const Color(0xFFFFB347),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                ],
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

  Widget _buildNodeResult() {
    final passed = _nodePassed;
    final color = passed ? NeuralColors.teal : const Color(0xFFFF4B6E);
    final agent = ref.watch(agentProvider);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.verified_rounded : Icons.cancel_outlined,
              color: color,
              size: 52,
            ),
            const SizedBox(height: 20),
            Text(
              passed
                  ? 'NODE ${widget.node.nodeNumber} CLEARED'
                  : 'NODE ${widget.node.nodeNumber} FAILED',
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
              widget.node.difficultyLabel.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: _difficultyColor(widget.node.difficulty),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            _resultRow(
              'Puzzles',
              '$_passedCount / ${widget.node.puzzleCount} passed',
            ),
            _resultRow('Score', '$_score pts'),
            if (agent != null)
              _resultRow('Intel', '${agent.intelPoints.toStringAsFixed(0)} IP'),
            if (agent != null) _resultRow('Chain', 'x${agent.chainMultiplier}'),
            _resultRow('Hints left', '🥕 x$_carrotsRemaining'),
            if (passed && _completing)
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
            if (_levelUp)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
              Button(
                text: 'Back to Nodes',
                onTap: () => Navigator.of(context).pop(true),
              )
            else ...[
              Button(
                text: 'Try Again',
                onTap: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
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

  Widget _resultRow(String label, String value) => Padding(
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

  Color _difficultyColor(NodeDifficulty d) => switch (d) {
    NodeDifficulty.standard => Colors.greenAccent,
    NodeDifficulty.secured => NeuralColors.teal,
    NodeDifficulty.critical => const Color(0xFFFFB347),
    NodeDifficulty.boss => const Color(0xFFFF4B6E),
  };
}
