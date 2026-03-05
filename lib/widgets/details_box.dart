import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/widgets/chain/chain.dart';

import 'package:neural_nexus_protocol/widgets/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/shield_count.dart';

class DetailsBox extends StatelessWidget {
  const DetailsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelBorder(
      child: SizedBox(
        width: 260,
        height: 200,
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          crossAxisAlignment: .center,
          children: [
            ShieldCount(),
            Text(
              'Next Shield in 00:00',
              style: GoogleFonts.pressStart2p(fontSize: 12),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  'Chain Multiplier:',
                  style: GoogleFonts.pressStart2p(fontSize: 12),
                ),
                const SizedBox(height: 15),
                ChainWidget(count: 5),
              ],
            ),
            Text('Points: XX', style: GoogleFonts.pressStart2p(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
