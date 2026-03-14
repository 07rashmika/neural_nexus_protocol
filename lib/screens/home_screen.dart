import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/screens/daily_challenge_screen.dart';
import 'package:neural_nexus_protocol/screens/leaderboard_screen.dart';
import 'package:neural_nexus_protocol/screens/sector_map.dart';
import 'package:neural_nexus_protocol/widgets/common/avatar_frame.dart';
import 'package:neural_nexus_protocol/widgets/common/logo_box.dart';
import 'package:neural_nexus_protocol/widgets/details_box.dart';
import 'package:neural_nexus_protocol/widgets/game_button.dart';
import 'package:neural_nexus_protocol/widgets/profile/profile_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.agent});

  final Agent agent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAgent = ref.watch(agentProvider) ?? agent;
    final fallbackText = liveAgent.username.isNotEmpty
        ? liveAgent.username.characters.first.toUpperCase()
        : 'A';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
          ),
          icon: const Icon(Icons.leaderboard),
        ),
        actions: [
          GestureDetector(
            onTap: () => showProfileDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: AvatarFrame(
                imageUrl: liveAgent.avatarUrl,
                fallbackText: fallbackText,
                size: 40,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoBox(),
              const SizedBox(height: 40),
              const SizedBox(height: 20),
              GameButton(
                text: 'sector map',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SectorMap()),
                ),
              ),
              const SizedBox(height: 20),
              GameButton(
                text: 'daily challenge',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DailyChallengeScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              const DetailsBox(),
            ],
          ),
        ),
      ),
    );
  }
}
