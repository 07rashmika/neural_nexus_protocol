import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/models/sector.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
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
      appBar: AppBar(
        toolbarHeight: 80,
        leading: FittedBox(
          fit: .scaleDown,
          alignment: .centerLeft,
          child: Padding(
            padding: const .only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: .min,
                children: [
                  const Icon(
                    Icons.arrow_back_ios,
                    color: NeuralColors.tealDim,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      color: NeuralColors.tealDim,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: GlowText(
          text:
              '${widget.sector.name.toUpperCase()} · ${widget.sector.subtitle.toUpperCase()}',
          fontSize: 11,
          fontWeight: .w700,
          letterSpacing: 2,
        ),
        centerTitle: true,
        backgroundColor: NeuralColors.bg2,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const .fromHeight(1.5),
          child: Container(height: 1.5, color: NeuralColors.teal),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: NeuralColors.teal),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              _error!,
              style: GoogleFonts.spaceMono(
                color: Colors.redAccent,
                fontSize: 11,
              ),
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadNodes,
              child: Text(
                'RETRY',
                style: GoogleFonts.spaceMono(
                  color: NeuralColors.teal,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      );
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
    // TODO: Navigate to game screen passing node
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => GameScreen(node: node)),
    // );
  }
}

// ─── Node Card ────────────────────────────────────────────────────────────────

