import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/providers/login_screen_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';
import 'package:neural_nexus_protocol/widgets/common/pixel_border.dart';
import 'package:neural_nexus_protocol/widgets/stat_bar.dart';

import '../info_row.dart';
import '../section_label.dart';
import 'dialog_footer.dart';
import 'dialog_header.dart';

void showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => const ProfileDialog(),
  );
}

class ProfileDialog extends ConsumerStatefulWidget {
  const ProfileDialog({super.key});

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  bool _editingUsername = false;
  bool _savingUsername = false;
  String? _usernameError;
  late TextEditingController _usernameCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(
      text: ref.read(agentProvider)?.username ?? '',
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    final newUsername = _usernameCtrl.text.trim();
    final agent = ref.read(agentProvider);
    if (agent == null) return;

    if (newUsername.isEmpty) {
      setState(() => _usernameError = 'Cannot be empty');
      return;
    }
    if (newUsername == agent.username) {
      setState(() => _editingUsername = false);
      return;
    }
    if (newUsername.length < 3) {
      setState(() => _usernameError = 'Min 3 characters');
      return;
    }

    setState(() {
      _savingUsername = true;
      _usernameError = null;
    });

    try {
      await ApiService.updateUsername(newUsername);
      ref.read(agentProvider.notifier).state = agent.copyWith(
        username: newUsername,
      );
      setState(() => _editingUsername = false);
    } catch (e) {
      setState(
        () => _usernameError = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _savingUsername = false);
    }
  }

  void _cancelEdit() {
    _usernameCtrl.text = ref.read(agentProvider)?.username ?? '';
    setState(() {
      _editingUsername = false;
      _usernameError = null;
    });
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ApiService.logout();
    ref.read(isLoginScreenProvider.notifier).state = true;
    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final agent = ref.watch(agentProvider);
    if (agent == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: PixelBorder(
        padding: EdgeInsets.zero,
        child: Container(
          color: NeuralColors.bg,
          constraints: const BoxConstraints(maxHeight: 560),
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
                      SectionLabel(text: 'identification'),
                      const SizedBox(height: 10),
                      _buildUsernameRow(),
                      InfoRow(
                        label: 'agent id',
                        value:
                            '#${agent.id.toString().substring(0, 8).toUpperCase()}',
                      ),
                      if (agent.callsign != null && agent.callsign!.isNotEmpty)
                        InfoRow(label: 'callsign', value: agent.callsign!),
                      if (agent.country != null && agent.country!.isNotEmpty)
                        InfoRow(label: 'region', value: agent.country!),
                      InfoRow(label: 'position', value: agent.position),
                      const SizedBox(height: 20),
                      SectionLabel(text: 'combat stats'),
                      const SizedBox(height: 10),
                      InfoRow(
                        label: 'level',
                        value: agent.level.toString(),
                        valueColor: NeuralColors.teal,
                      ),
                      InfoRow(
                        label: 'streak',
                        value: '${agent.streak}x',
                        valueColor: agent.streak > 0 ? NeuralColors.teal : null,
                      ),
                      InfoRow(
                        label: 'shields',
                        value: '🛡 x${agent.shieldCount}',
                      ),
                      InfoRow(
                        label: 'chain mult',
                        value: '${agent.chainMultiplier}x',
                        valueColor: NeuralColors.teal,
                      ),
                      const SizedBox(height: 12),
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

  Widget _buildUsernameRow() {
    return Padding(
      padding: const .symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  'USERNAME',
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    color: _editingUsername
                        ? NeuralColors.teal
                        : NeuralColors.textDim,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 12,
                color: _editingUsername
                    ? NeuralColors.teal
                    : NeuralColors.tealBorder,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _editingUsername
                    ? TextField(
                        controller: _usernameCtrl,
                        autofocus: true,
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          color: NeuralColors.textMain,
                          letterSpacing: 1,
                        ),
                        cursorColor: NeuralColors.teal,
                        textCapitalization: .none,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: .zero,
                          border: .none,
                          hintText: 'new username',
                          hintStyle: GoogleFonts.spaceMono(
                            fontSize: 12,
                            color: NeuralColors.tealDark,
                          ),
                        ),
                        onSubmitted: (_) => _saveUsername(),
                      )
                    : Text(
                        ref.read(agentProvider)!.username.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          color: NeuralColors.textMain,
                          letterSpacing: 1,
                        ),
                      ),
              ),
              // Action icons
              if (_savingUsername)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: NeuralColors.teal,
                  ),
                )
              else if (_editingUsername) ...[
                GestureDetector(
                  onTap: () async {
                    await AppAudioService.instance.playSoftTap();
                    _saveUsername();
                  },
                  child: const Padding(
                    padding: .only(left: 8),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: NeuralColors.teal,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await AppAudioService.instance.playSoftTap();
                    _cancelEdit();
                  },
                  child: const Padding(
                    padding: .only(left: 6),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFFFF4B6E),
                    ),
                  ),
                ),
              ] else
                GestureDetector(
                  onTap: () async {
                    await AppAudioService.instance.playSoftTap();
                    setState(() {
                      _editingUsername = true;
                      _usernameError = null;
                    });
                  },
                  child: const Padding(
                    padding: .only(left: 8),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: NeuralColors.tealDim,
                    ),
                  ),
                ),
            ],
          ),
          if (_usernameError != null)
            Padding(
              padding: const .only(top: 4, left: 102),
              child: Text(
                _usernameError!,
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: const Color(0xFFFF4B6E),
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
