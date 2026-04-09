import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/shield_provider.dart';
import 'package:neural_nexus_protocol/widgets/chain/chain.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class DetailsBox extends ConsumerWidget {
  const DetailsBox({super.key});

  static const int _maxChain = 5;

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agent = ref.watch(agentProvider);
    final shields = ref.watch(shieldProvider);

    if (agent == null) return const SizedBox.shrink();

    final chainActive = agent.chainMultiplier.clamp(0, _maxChain);

    return PixelBorder(
      child: SizedBox(
        width: 260,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShieldCount(count: shields.count, max: ShieldState.max),
            Text(
              shields.isFull
                  ? 'Shields Full'
                  : 'Next Shield in ${_formatTime(shields.secondsUntilNext)}',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: shields.isFull
                    ? NeuralColors.teal
                    : NeuralColors.tealDim,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              children: [
                Text(
                  'Chain ×$chainActive',
                  style: GoogleFonts.pressStart2p(fontSize: 10),
                ),
                const SizedBox(height: 12),
                ChainWidget(count: _maxChain, activeCount: chainActive),
              ],
            ),
            Text(
              '${agent.intelPoints.toStringAsFixed(0)} IP',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
