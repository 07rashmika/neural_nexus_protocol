import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/providers/login_screen_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
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

class ProfileDialog extends ConsumerWidget {
  const ProfileDialog({super.key, required this.agent});

  final Agent agent;

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ApiService.logout();

    // Reset auth screen back to login mode for the next session
    ref.read(isLoginScreenProvider.notifier).state = true;

    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: PixelBorder(
        padding: EdgeInsets.zero,
        child: Container(
          color: NeuralColors.bg,
          constraints: const BoxConstraints(maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogHeader(agent: agent),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Identification ──────────────────────────────────
                      SectionLabel(text: 'identification'),
                      const SizedBox(height: 10),
                      InfoRow(label: 'username', value: agent.username),
                      InfoRow(
                        label: 'agent id',
                        value: '#${agent.id.toString().padLeft(6, '0')}',
                      ),
                      InfoRow(label: 'position', value: agent.position),

                      const SizedBox(height: 20),

                      // ── Progress ────────────────────────────────────────
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
              DialogFooter(onLogout: () => _handleLogout(context, ref)),
            ],
          ),
        ),
      ),
    );
  }
}
