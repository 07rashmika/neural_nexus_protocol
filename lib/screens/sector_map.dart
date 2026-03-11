import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/sector.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/glow_text.dart';
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
      appBar: AppBar(
        toolbarHeight: 80,
        leading: FittedBox(
          fit: .scaleDown,
          alignment: .centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisSize: .min,
              children: [
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_back_ios,
                  color: NeuralColors.tealDim,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'BACK',
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    color: NeuralColors.tealDim,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: GlowText(
          text: 'SECTOR MAP',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
        centerTitle: true,
        backgroundColor: NeuralColors.bg2,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
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
              onTap: loadSectors,
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
