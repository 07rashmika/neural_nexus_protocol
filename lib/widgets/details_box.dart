import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/widgets/chain/chain.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class DetailsBox extends ConsumerStatefulWidget {
  const DetailsBox({super.key});

  @override
  ConsumerState<DetailsBox> createState() => _DetailsBoxState();
}

class _DetailsBoxState extends ConsumerState<DetailsBox> {
  static const int _maxShields = 3;
  static const int _maxChain = 5;
  static const double _pointsPerChain = 1000.0;
  static const int _regenSeconds = 15 * 60; // 15 minutes

  Timer? _timer;
  int _secondsRemaining = _regenSeconds;

  @override
  void initState() {
    super.initState();
    _syncCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final agent = ref.read(agentProvider);
      if (agent == null) return;

      if (agent.shieldCount >= _maxShields) {
        setState(() => _secondsRemaining = _regenSeconds);
        return;
      }

      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          final newCount = (agent.shieldCount + 1).clamp(0, _maxShields);
          final clearTimestamp = newCount >= _maxShields;
          ref.read(agentProvider.notifier).state = agent.copyWith(
            shieldCount: newCount,
            clearLastShieldLostAt: clearTimestamp,
            lastShieldLostAt: clearTimestamp
                ? null
                : agent.lastShieldLostAt?.add(
                    const Duration(seconds: _regenSeconds),
                  ),
          );
          _secondsRemaining = _regenSeconds;
        }
      });
    });
  }

  /// Sync the countdown with the real lastShieldLostAt timestamp from backend
  void _syncCountdown() {
    final agent = ref.read(agentProvider);
    if (agent == null || agent.lastShieldLostAt == null) {
      _secondsRemaining = _regenSeconds;
      return;
    }
    if (agent.shieldCount >= _maxShields) {
      _secondsRemaining = _regenSeconds;
      return;
    }

    final now = DateTime.now().toUtc();
    final lostAt = agent.lastShieldLostAt!.toUtc();
    final elapsed = now.difference(lostAt).inSeconds;
    final remaining = _regenSeconds - (elapsed % _regenSeconds);
    _secondsRemaining = remaining.clamp(0, _regenSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _calcChain(double intelPoints) {
    return (intelPoints / _pointsPerChain).floor().clamp(0, _maxChain);
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final agent = ref.watch(agentProvider);
    if (agent == null) return const SizedBox.shrink();

    final shieldCount = agent.shieldCount.clamp(0, _maxShields);
    final chainActive = _calcChain(agent.intelPoints);
    final shieldsFull = shieldCount >= _maxShields;

    return PixelBorder(
      child: SizedBox(
        width: 260,
        height: 200,
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          crossAxisAlignment: .center,
          children: [
            ShieldCount(count: shieldCount, max: _maxShields),
            Text(
              shieldsFull
                  ? 'Shields Full'
                  : 'Next Shield in ${_formatTime(_secondsRemaining)}',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: shieldsFull ? NeuralColors.teal : NeuralColors.tealDim,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              children: [
                Text(
                  'Chain Multiplier:',
                  style: GoogleFonts.pressStart2p(fontSize: 10),
                ),
                const SizedBox(height: 12),
                ChainWidget(count: _maxChain, activeCount: chainActive),
              ],
            ),
            Text(
              'Points: ${agent.intelPoints.toStringAsFixed(0)}',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
