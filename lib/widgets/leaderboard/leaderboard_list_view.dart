import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/leaderboard/leaderboard_row.dart';

class LeaderboardListView extends StatelessWidget {
  const LeaderboardListView({
    super.key,
    required this.entries,
    required this.onRefresh,
  });

  final List<Map<String, dynamic>> entries;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: NeuralColors.teal,
      backgroundColor: NeuralColors.bg2,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: entries.length,
        itemBuilder: (_, i) => LeaderboardRow(
          entry: entries[i],
          maxIntel: (entries.first['intel_points'] as num).toDouble(),
        ),
      ),
    );
  }
}
