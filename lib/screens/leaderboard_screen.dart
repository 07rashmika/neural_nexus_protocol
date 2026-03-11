import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getLeaderboard();
      setState(() {
        _entries = List<Map<String, dynamic>>.from(data['leaderboard'] as List);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuralColors.bg,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: NeuralColors.bg2,
        automaticallyImplyLeading: false,
        leading: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_back_ios, color: NeuralColors.tealDim, size: 12),
                const SizedBox(width: 4),
                Text('BACK', style: GoogleFonts.spaceMono(
                    fontSize: 11, color: NeuralColors.tealDim, letterSpacing: 1)),
              ]),
            ),
          ),
        ),
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('LEADERBOARD', style: GoogleFonts.spaceMono(
              fontSize: 13, color: NeuralColors.teal,
              fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(height: 2),
          Text('TOP AGENTS BY INTEL', style: GoogleFonts.spaceMono(
              fontSize: 9, color: NeuralColors.tealDim, letterSpacing: 2)),
        ]),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(height: 1.5, color: NeuralColors.teal),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: NeuralColors.teal));
    }
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, style: GoogleFonts.spaceMono(
            fontSize: 11, color: const Color(0xFFFF4B6E)),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _load,
          child: Text('RETRY', style: GoogleFonts.spaceMono(
              fontSize: 11, color: NeuralColors.teal, letterSpacing: 2)),
        ),
      ]));
    }
    if (_entries.isEmpty) {
      return Center(child: Text('NO AGENTS YET', style: GoogleFonts.spaceMono(
          fontSize: 11, color: NeuralColors.tealDim, letterSpacing: 3)));
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

// ─── Row ──────────────────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.maxIntel});

  final Map<String, dynamic> entry;
  final double maxIntel;

  Color get _rankColor {
    final rank = entry['rank'] as int;
    return switch (rank) {
      1 => const Color(0xFFFFD700), // gold
      2 => const Color(0xFFC0C0C0), // silver
      3 => const Color(0xFFCD7F32), // bronze
      _ => NeuralColors.tealDim,
    };
  }

  @override
  Widget build(BuildContext context) {
    final rank      = entry['rank']    as int;
    final username  = entry['username'] as String? ?? 'agent';
    final intel     = (entry['intel_points'] as num).toDouble();
    final level     = entry['level']   as int? ?? 1;
    final position  = entry['position'] as String? ?? '';
    final dailies   = entry['daily_challenges_completed'] as int? ?? 0;
    final streak    = entry['streak']  as int? ?? 0;
    final avatarUrl = entry['avatar_url'] as String?;
    final isSelf    = entry['isCurrentPlayer'] as bool? ?? false;
    final fraction  = maxIntel > 0 ? (intel / maxIntel).clamp(0.0, 1.0) : 0.0;

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
            // ── Top row ───────────────────────────────────────────
            Row(children: [
              // Rank
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

              // Avatar
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: _rankColor.withValues(alpha: 0.4)),
                  shape: BoxShape.rectangle,
                ),
                clipBehavior: Clip.hardEdge,
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? SvgPicture.network(avatarUrl,
                        fit: BoxFit.cover,
                        placeholderBuilder: (_) => Container(
                          color: NeuralColors.bg2,
                          child: Center(child: Text(
                            username[0].toUpperCase(),
                            style: GoogleFonts.spaceMono(
                                fontSize: 12, color: NeuralColors.teal),
                          )),
                        ))
                    : Center(child: Text(
                        username[0].toUpperCase(),
                        style: GoogleFonts.spaceMono(
                            fontSize: 12, color: NeuralColors.teal))),
              ),

              const SizedBox(width: 10),

              // Username + position
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(
                          username.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            color: isSelf ? NeuralColors.teal : NeuralColors.textMain,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          color: NeuralColors.teal.withValues(alpha: 0.15),
                          child: Text('YOU', style: GoogleFonts.spaceMono(
                              fontSize: 8, color: NeuralColors.teal, letterSpacing: 1)),
                        ),
                      ],
                    ]),
                    Text(
                      'LVL $level · $position'.toUpperCase(),
                      style: GoogleFonts.spaceMono(
                          fontSize: 8, color: NeuralColors.tealDim, letterSpacing: 1),
                    ),
                  ],
                ),
              ),

              // Intel points
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  _formatIntel(intel),
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    color: isSelf ? NeuralColors.teal : NeuralColors.textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('IP', style: GoogleFonts.spaceMono(
                    fontSize: 8, color: NeuralColors.tealDim, letterSpacing: 2)),
              ]),
            ]),

            const SizedBox(height: 8),

            // ── Intel bar ─────────────────────────────────────────
            ClipRect(
              child: Container(
                height: 2, width: double.infinity, color: NeuralColors.tealDark,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: isSelf ? NeuralColors.teal : _rankColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Stats row ─────────────────────────────────────────
            Row(children: [
              _chip('🔥 $dailies dailies',
                  dailies > 0 ? const Color(0xFFFFB347) : NeuralColors.tealDark),
              const SizedBox(width: 10),
              if (streak > 0)
                _chip('⚡ ${streak}x streak', NeuralColors.teal),
            ]),
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
      child: Text(text, style: GoogleFonts.spaceMono(
          fontSize: 8, color: color, letterSpacing: 1)),
    );
  }

  String _formatIntel(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}