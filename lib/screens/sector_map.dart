import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/widgets/glow_text.dart';

class SectorMap extends StatelessWidget {
  const SectorMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GlowText(
          text: 'Sector Map',
          fontSize: 22,
          fontWeight: .w600,
          letterSpacing: 0,
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.shield))],
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: const Placeholder(),
    );
  }
}
