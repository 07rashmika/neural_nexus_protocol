import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/avatar_frame.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    required this.onAvatarSelected,
  });

  final void Function(String avatarUrl) onAvatarSelected;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  late List<String> _avatarOptions;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _avatarOptions = ApiService.generateAvatarOptions(count: 6);
    _selectedAvatar = _avatarOptions.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAvatarSelected(_selectedAvatar);
    });
  }

  void _refresh() async {
    await AppAudioService.instance.playButtonTap();
    setState(() {
      _avatarOptions = ApiService.generateAvatarOptions(count: 6);
      _selectedAvatar = _avatarOptions.first;
    });
    widget.onAvatarSelected(_selectedAvatar);
  }

  void _select(String url) async {
    await AppAudioService.instance.playSoftTap();
    setState(() => _selectedAvatar = url);
    widget.onAvatarSelected(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AvatarFrame(
            imageUrl: _selectedAvatar,
            fallbackText: 'A',
            size: 110,
            padding: const EdgeInsets.all(10),
            backgroundColor: NeuralColors.teal.withValues(alpha: 0.05),
            glowOpacity: 0.15,
            placeholder: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: NeuralColors.tealDim,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _avatarOptions.length,
          itemBuilder: (_, i) {
            final url = _avatarOptions[i];
            final selected = url == _selectedAvatar;
            return GestureDetector(
              onTap: () => _select(url),
              child: AvatarFrame(
                imageUrl: url,
                fallbackText: 'A',
                size: 48,
                padding: const EdgeInsets.all(4),
                fit: BoxFit.contain,
                borderColor: selected
                    ? NeuralColors.teal
                    : NeuralColors.tealDark,
                borderWidth: selected ? 2 : 1,
                glowOpacity: selected ? 0.15 : 0,
                backgroundColor: selected
                    ? NeuralColors.teal.withValues(alpha: 0.1)
                    : Colors.transparent,
                placeholder: const SizedBox(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh, color: NeuralColors.tealDim, size: 16),
          label: Text(
            'GENERATE NEW AVATARS',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: NeuralColors.tealDim,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}