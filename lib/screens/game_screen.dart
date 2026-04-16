import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/game_puzzle_body.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/game_screen_header.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/no_shields_dialog.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/node_progress_bar.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/node_result_panel.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/pause_dialog.dart';
import 'package:neural_nexus_protocol/widgets/gameScreen/puzzle_timer_bar.dart';

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

  void _restartLevel() {
    _timer?.cancel();

    if (ref.read(shieldProvider).isEmpty) {
      _showNoShieldsDialog();
      return;
    }

    setState(() {
      _puzzleIndex = 0;
      _passedCount = 0;
      _livesLeft = widget.node.lives;
      _nodeDone = false;
      _nodePassed = false;
      _completing = false;
      _selectedAnswer = null;
      _answerCorrect = null;
      _answered = false;
      _score = 0;
      _hintVisible = false;
      _hintUsedThisPuzzle = false;
      _usingHint = false;
      _levelUp = false;
      _paused = false;
      _timeLeft = _timerSeconds;
    });
    _fetchPuzzle();
  }

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
    return GameScreenHeader(
      shields: shields,
      agent: ref.watch(agentProvider),
      node: widget.node,
      livesLeft: _livesLeft,
      score: _score,
      chainMultiplier: _chainMultiplier,
      nodeDone: _nodeDone,
      onPause: _onPause,
    );
  }

  Widget _buildNodeProgressBar() {
    return NodeProgressBar(
      node: widget.node,
      puzzleIndex: _puzzleIndex,
      answered: _answered,
      answerCorrect: _answerCorrect,
    );
  }

  Widget _buildTimerBar() {
    return PuzzleTimerBar(timeLeft: _timeLeft, totalSeconds: _timerSeconds);
  }

  Widget _buildPuzzleBody() {
    return GamePuzzleBody(
      isLoading: _loading,
      error: _error,
      questionUrl: _questionUrl,
      answered: _answered,
      answerCorrect: _answerCorrect,
      selectedAnswer: _selectedAnswer,
      solution: _solution,
      timeLeft: _timeLeft,
      chainMultiplier: _chainMultiplier,
      hintVisible: _hintVisible,
      hintValue: _carrots,
      carrotsRemaining: _carrotsRemaining,
      hintUsedThisPuzzle: _hintUsedThisPuzzle,
      usingHint: _usingHint,
      paused: _paused,
      showChainBreakText: true,
      showCorrectAnswerOnTimeout: false,
      isLastPuzzle: _puzzleIndex + 1 >= widget.node.puzzleCount,
      nodeDone: _nodeDone,
      animation: _glowAnim,
      onRetry: _fetchPuzzle,
      onUseHint: _onUseHint,
      onAnswer: _onAnswer,
      onNextPuzzle: _onNextPuzzle,
    );
  }

  Widget _buildNodeResult() {
    return NodeResultPanel(
      node: widget.node,
      passed: _nodePassed,
      passedCount: _passedCount,
      score: _score,
      agent: ref.watch(agentProvider),
      carrotsRemaining: _carrotsRemaining,
      completing: _completing,
      levelUp: _levelUp,
      onBackSuccess: () => _backToNodes(true),
      onTryAgain: _restartLevel,
    );
  }
}
