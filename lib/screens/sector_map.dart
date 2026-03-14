import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/sector.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';
import 'package:neural_nexus_protocol/widgets/common/async_state_view.dart';
import 'package:neural_nexus_protocol/widgets/common/retro_back_app_bar.dart';
import 'package:neural_nexus_protocol/widgets/sectorMap/overall_progress.dart';
import 'package:neural_nexus_protocol/widgets/sectorMap/sector_card.dart';

class SectorMap extends StatefulWidget {
  const SectorMap({super.key});

  @override
  State<SectorMap> createState() => _SectorMapState();
}

class _SectorMapState extends State<SectorMap> {
  List<Sector> _sectors = [];
  int _totalNodes = 0;
  int _completedNodes = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppAudioService.instance.ensureBackgroundMusic();
    });
    loadSectors();
  }

  Future<void> loadSectors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getSectors();
      setState(() {
        _sectors = data['sectors'] as List<Sector>;
        _totalNodes = data['totalNodes'] as int;
        _completedNodes = data['completedNodes'] as int;
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
      appBar: const RetroBackAppBar(title: 'SECTOR MAP'),
      backgroundColor: Colors.transparent,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AsyncStateView.loading();
    }
    if (_error != null) {
      return AsyncStateView.error(error: _error!, onRetry: loadSectors);
    }
    return RefreshIndicator(
      color: NeuralColors.teal,
      backgroundColor: NeuralColors.bg2,
      onRefresh: loadSectors,
      child: ListView(
        padding: const .symmetric(horizontal: 24, vertical: 40),
        children: [
          ..._sectors.map((s) => SectorCard(sector: s, onReturn: loadSectors)),
          const SizedBox(height: 40),
          OverallProgress(completed: _completedNodes, total: _totalNodes),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
