import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/widgets/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/stat_bar.dart';

import '../info_row.dart';
import '../section_label.dart';
import 'dialog_footer.dart';
import 'dialog_header.dart';

void showProfileDialog(BuildContext context, {required Agent agent}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => ProfileDialog(agent: agent),
  );
}

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.agent});

  final Agent agent;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const .symmetric(horizontal: 24, vertical: 40),
      child: PixelBorder(
        padding: .zero,
        child: Container(
          color: NeuralColors.bg,
          constraints: const BoxConstraints(maxHeight: 520),
          child: Column(
            mainAxisSize: .min,
            children: [
              DialogHeader(agent: agent),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const .fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      // ── Identification ─────────────────────────────────────
                      SectionLabel(text: 'identification'),
                      const SizedBox(height: 10),
                      InfoRow(label: 'username', value: agent.username),
                      InfoRow(
                        label: 'agent id',
                        value: '#${agent.id.toString().padLeft(6, '0')}',
                      ),
                      InfoRow(label: 'position', value: agent.position),

                      const SizedBox(height: 20),

                      // ── Progress ───────────────────────────────────────────
                      SectionLabel(text: 'agent progress'),
                      const SizedBox(height: 10),
                      InfoRow(
                        label: 'level',
                        value: agent.level.toString(),
                        valueColor: NeuralColors.teal,
                      ),
                      StatBar(
                        label: 'intel points',
                        rawValue: agent.intelPoints,
                        displayValue: agent.intelPoints.toStringAsFixed(0),
                        maxValue: 2.5,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              DialogFooter(onClose: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────
