import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/async_state_view.dart';
import 'package:neural_nexus_protocol/widgets/common/empty_state_view.dart';
import 'package:neural_nexus_protocol/widgets/common/retro_back_app_bar.dart';
import 'package:neural_nexus_protocol/widgets/leaderboard/leaderboard_list_view.dart';

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

    return LeaderboardListView(entries: _entries, onRefresh: _load);
  }
}
