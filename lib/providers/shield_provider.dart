import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';

// ── Public state exposed by ShieldNotifier ────────────────────────────────────

class ShieldState {
  const ShieldState({
    required this.count,
    required this.secondsUntilNext,
    required this.syncing,
  });

  final int count; // 0–3
  final int secondsUntilNext; // countdown to next regen (0 when full)
  final bool syncing; // true while a backend call is in flight

  static const int max = 3;
  static const int regenSeconds = 10 * 60; // 10 minutes

  bool get isFull => count >= max;
  bool get isEmpty => count <= 0;

  ShieldState copyWith({int? count, int? secondsUntilNext, bool? syncing}) =>
      ShieldState(
        count: count ?? this.count,
        secondsUntilNext: secondsUntilNext ?? this.secondsUntilNext,
        syncing: syncing ?? this.syncing,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ShieldNotifier extends Notifier<ShieldState> {
  static const int _max = ShieldState.max;
  static const int _regenSec = ShieldState.regenSeconds;

  Timer? _ticker;

  @override
  ShieldState build() {
    // Seed from agentProvider so the UI is never blank on first frame
    final agent = ref.read(agentProvider);
    final initial = _stateFromAgent(agent);

    // Start the local ticker
    _startTicker();

    // Clean up timer when provider is disposed
    ref.onDispose(() => _ticker?.cancel());

    return initial;
  }

  // ── Called once on GameScreen entry and whenever home re-appears ─────────
  Future<void> sync() async {
    state = state.copyWith(syncing: true);
    debugPrint('[ShieldProvider] sync() started');

    const timeout = Duration(seconds: 8);

    Map<String, dynamic>? shieldData;
    Agent? freshAgent;

    try {
      debugPrint('[ShieldProvider] calling syncShields...');
      shieldData = await ApiService.syncShields().timeout(timeout);
      debugPrint('[ShieldProvider] syncShields done: $shieldData');
    } catch (e) {
      debugPrint('[ShieldProvider] syncShields error: $e');
      shieldData = null;
    }

    try {
      debugPrint('[ShieldProvider] calling getProfile...');
      freshAgent = await ApiService.getProfile().timeout(timeout);
      debugPrint('[ShieldProvider] getProfile done: ${freshAgent.username}');
    } catch (e) {
      debugPrint('[ShieldProvider] getProfile error: $e');
      freshAgent = null;
    }

    // shields endpoint is authoritative — it runs _recomputeShields on the backend.
    // getProfile does NOT run regen math, so we must apply shield data AFTER
    // the profile write, overwriting whatever stale shield values came from profile.
    final agent = ref.read(agentProvider);
    if (agent != null) {
      // Step 1: write fresh profile (non-shield fields: username, avatar, etc.)
      if (freshAgent != null) {
        ref.read(agentProvider.notifier).state = freshAgent;
      }

      // Step 2: always overwrite shield fields from the shields endpoint,
      // which is the only source that runs regen math.
      if (shieldData != null) {
        final currentAgent = ref.read(agentProvider) ?? agent;
        final newCount =
            shieldData['shield_count'] as int? ?? currentAgent.shieldCount;
        final rawTs = shieldData['last_shield_lost_at'] as String?;
        final lostAt = rawTs != null ? DateTime.tryParse(rawTs) : null;
        ref.read(agentProvider.notifier).state = currentAgent.copyWith(
          shieldCount: newCount,
          lastShieldLostAt: lostAt,
          clearLastShieldLostAt: lostAt == null,
        );
      }
    }

    // Build shield state from the now-authoritative agentProvider
    final updated = ref.read(agentProvider);
    state = _stateFromAgent(updated).copyWith(syncing: false);
    _restartTicker();
  }

  // ── Called by GameScreen after a wrong answer / timeout ─────────────────
  void deductOne() {
    // Optimistic — immediately reflect in UI before backend confirms
    final newCount = (state.count - 1).clamp(0, _max);
    state = state.copyWith(
      count: newCount,
      secondsUntilNext: newCount < _max ? state.secondsUntilNext : _regenSec,
      syncing: true,
    );
    _restartTicker();
  }

  // ── Called by GameScreen with the authoritative shieldData from /game/submit
  void applyBackendResult(Map<String, dynamic> shieldData) {
    final newCount = shieldData['shield_count'] as int? ?? state.count;
    final rawTs = shieldData['last_shield_lost_at'] as String?;
    final lostAt = rawTs != null ? DateTime.tryParse(rawTs) : null;

    // Keep agentProvider in sync too
    final agent = ref.read(agentProvider);
    if (agent != null) {
      ref.read(agentProvider.notifier).state = agent.copyWith(
        shieldCount: newCount,
        lastShieldLostAt: lostAt,
        clearLastShieldLostAt: lostAt == null,
      );
    }

    state = ShieldState(
      count: newCount,
      secondsUntilNext: _calcSecondsRemaining(lostAt, newCount),
      syncing: false,
    );
    _restartTicker();
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  ShieldState _stateFromAgent(Agent? agent) {
    final count = agent?.shieldCount ?? _max;
    final lostAt = agent?.lastShieldLostAt;
    return ShieldState(
      count: count,
      secondsUntilNext: _calcSecondsRemaining(lostAt, count),
      syncing: false,
    );
  }

  int _calcSecondsRemaining(DateTime? lostAt, int count) {
    if (count >= _max || lostAt == null) return _regenSec;
    final elapsed = DateTime.now().toUtc().difference(lostAt.toUtc()).inSeconds;
    return (_regenSec - (elapsed % _regenSec)).clamp(0, _regenSec);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _restartTicker() {
    _startTicker();
  }

  void _tick() {
    if (state.isFull) {
      // Nothing to count down
      if (state.secondsUntilNext != _regenSec) {
        state = state.copyWith(secondsUntilNext: _regenSec);
      }
      return;
    }

    final next = state.secondsUntilNext - 1;

    if (next <= 0) {
      // Regen one shield
      final newCount = (state.count + 1).clamp(0, _max);
      final isFull = newCount >= _max;

      // Keep agentProvider in sync
      final agent = ref.read(agentProvider);
      if (agent != null) {
        ref.read(agentProvider.notifier).state = agent.copyWith(
          shieldCount: newCount,
          clearLastShieldLostAt: isFull,
          lastShieldLostAt: isFull
              ? null
              : agent.lastShieldLostAt?.add(const Duration(seconds: _regenSec)),
        );
      }

      state = ShieldState(
        count: newCount,
        secondsUntilNext: isFull ? _regenSec : _regenSec,
        syncing: false,
      );
    } else {
      state = state.copyWith(secondsUntilNext: next);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final shieldProvider = NotifierProvider<ShieldNotifier, ShieldState>(
  ShieldNotifier.new,
);
