import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/screens/game_screen.dart';
import 'package:neural_nexus_protocol/screens/sector_map.dart';
import 'package:neural_nexus_protocol/widgets/common/details_box.dart';
import 'package:neural_nexus_protocol/widgets/game_button.dart';
import 'package:neural_nexus_protocol/widgets/common/logo_box.dart';
import 'package:neural_nexus_protocol/widgets/profile/profile_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.agent});

  final Agent agent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          onPressed: () => showProfileDialog(context, agent: widget.agent),
          icon: const Icon(Icons.leaderboard),
        ),
        actions: [
          IconButton(
            onPressed: () => showProfileDialog(context, agent: widget.agent),
            icon: const Icon(Icons.person),
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
              GameButton(
                text: 'start mission',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                ),
              ),
              const SizedBox(height: 20),
              GameButton(
                text: 'sector map',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SectorMap()),
                ),
              ),
              const SizedBox(height: 20),
              GameButton(text: 'daily challenge', onTap: () {}),
              const SizedBox(height: 60),
              const DetailsBox(),
            ],
          ),
        ),
      ),
    );
  }
}