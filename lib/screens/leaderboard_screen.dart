import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/async_state_view.dart';
import 'package:neural_nexus_protocol/widgets/common/avatar_frame.dart';
import 'package:neural_nexus_protocol/widgets/common/empty_state_view.dart';
import 'package:neural_nexus_protocol/widgets/common/retro_back_app_bar.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getLeaderboard();
      setState(() {
        _entries = List<Map<String, dynamic>>.from(data['leaderboard'] as List);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuralColors.bg,
      appBar: const RetroBackAppBar(
        title: 'LEADERBOARD',
        titleFontSize: 13,
        titleLetterSpacing: 3,
        backFontSize: 11,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AsyncStateView.loading(message: 'LOADING RANKS...');
    }
    if (_error != null) {
      return AsyncStateView.error(error: _error!, onRetry: _load);
    }
    if (_entries.isEmpty) {
      return const EmptyStateView(message: 'NO AGENTS YET');
    }

    return RefreshIndicator(
      color: NeuralColors.teal,
      backgroundColor: NeuralColors.bg2,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _entries.length,
        itemBuilder: (_, i) => _LeaderboardRow(
          entry: _entries[i],
          maxIntel: (_entries.first['intel_points'] as num).toDouble(),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.maxIntel});

  final Map<String, dynamic> entry;
  final double maxIntel;

  Color get _rankColor {
    final rank = entry['rank'] as int;
    return switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => NeuralColors.tealDim,
    };
  }

  @override
  Widget build(BuildContext context) {
    final rank = entry['rank'] as int;
    final username = entry['username'] as String? ?? 'agent';
    final intel = (entry['intel_points'] as num).toDouble();
    final level = entry['level'] as int? ?? 1;
    final position = entry['position'] as String? ?? '';
    final dailies = entry['daily_challenges_completed'] as int? ?? 0;
    final streak = entry['streak'] as int? ?? 0;
    final avatarUrl = entry['avatar_url'] as String?;
    final isSelf = entry['isCurrentPlayer'] as bool? ?? false;
    final fraction = maxIntel > 0 ? (intel / maxIntel).clamp(0.0, 1.0) : 0.0;
    final fallbackText = username.isNotEmpty ? username[0].toUpperCase() : 'A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelf
              ? NeuralColors.teal
              : rank <= 3
              ? _rankColor.withValues(alpha: 0.5)
              : NeuralColors.tealDark,
          width: isSelf ? 1.5 : 1,
        ),
        color: isSelf
            ? NeuralColors.teal.withValues(alpha: 0.05)
            : NeuralColors.bg2,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#$rank',
                    style: GoogleFonts.spaceMono(
                      fontSize: rank <= 3 ? 14 : 11,
                      color: _rankColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AvatarFrame(
                  imageUrl: avatarUrl,
                  fallbackText: fallbackText,
                  size: 32,
                  padding: EdgeInsets.zero,
                  borderColor: _rankColor.withValues(alpha: 0.4),
                  borderWidth: 1,
                  fit: BoxFit.cover,
                  backgroundColor: NeuralColors.bg2,
                  glowOpacity: 0,
                  fallbackFontSize: 12,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username.toUpperCase(),
                              style: GoogleFonts.spaceMono(
                                fontSize: 11,
                                color: isSelf
                                    ? NeuralColors.teal
                                    : NeuralColors.textMain,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              color: NeuralColors.teal.withValues(alpha: 0.15),
                              child: Text(
                                'YOU',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 8,
                                  color: NeuralColors.teal,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'LVL $level · $position'.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          fontSize: 8,
                          color: NeuralColors.tealDim,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatIntel(intel),
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        color: isSelf
                            ? NeuralColors.teal
                            : NeuralColors.textMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'IP',
                      style: GoogleFonts.spaceMono(
                        fontSize: 8,
                        color: NeuralColors.tealDim,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRect(
              child: Container(
                height: 2,
                width: double.infinity,
                color: NeuralColors.tealDark,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: isSelf
                        ? NeuralColors.teal
                        : _rankColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip(
                  '🔥 $dailies dailies',
                  dailies > 0 ? const Color(0xFFFFB347) : NeuralColors.tealDark,
                ),
                const SizedBox(width: 10),
                if (streak > 0) _chip('⚡ ${streak}x streak', NeuralColors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        color: color.withValues(alpha: 0.06),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceMono(
          fontSize: 8,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _formatIntel(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }
}
