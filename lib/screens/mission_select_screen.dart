import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/models/sector.dart';
import 'package:neural_nexus_protocol/screens/game_screen.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/async_state_view.dart';
import 'package:neural_nexus_protocol/widgets/common/retro_back_app_bar.dart';
import 'package:neural_nexus_protocol/widgets/missionSelect/node_card.dart';

class MissionSelectScreen extends StatefulWidget {
  const MissionSelectScreen({super.key, required this.sector});

  final Sector sector;

  @override
  State<MissionSelectScreen> createState() => _MissionSelectScreenState();
}

class _MissionSelectScreenState extends State<MissionSelectScreen> {
  List<NodeModel> _nodes = [];
  bool _loading = true;
  String? _error;
  int _carrotsRemaining = 3;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getNodes(widget.sector.code);
      setState(() {
        _nodes = data['nodes'] as List<NodeModel>;
        _carrotsRemaining = data['carrotsRemaining'] as int? ?? 3;
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
      appBar: RetroBackAppBar(
        title: '${widget.sector.name.toUpperCase()} · ${widget.sector.subtitle.toUpperCase()}',
        titleFontSize: 11,
        titleLetterSpacing: 2,
        leadingPadding: const EdgeInsets.only(left: 16),
      ),
      backgroundColor: Colors.transparent,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AsyncStateView.loading();
    }
    if (_error != null) {
      return AsyncStateView.error(error: _error!, onRetry: _loadNodes);
    }

    return RefreshIndicator(
      color: NeuralColors.teal,
      backgroundColor: NeuralColors.bg2,
      onRefresh: _loadNodes,
      child: GridView.builder(
        padding: const .all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _nodes.length,
        itemBuilder: (_, i) =>
            NodeCard(node: _nodes[i], onStart: () => _onStartNode(_nodes[i])),
      ),
    );
  }

  void _onStartNode(NodeModel node) {
    if (node.isLocked || node.isCompleted) return;
    Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GameScreen(
        node: node,
        sectorCode: widget.sector.code,
        carrotsRemaining: _carrotsRemaining, // ← pass it
      ),
    ),
  ).then((_) => _loadNodes());
  }
}