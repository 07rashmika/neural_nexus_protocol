import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';

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

  void _refresh() {
    setState(() {
      _avatarOptions = ApiService.generateAvatarOptions(count: 6);
      _selectedAvatar = _avatarOptions.first;
    });
    widget.onAvatarSelected(_selectedAvatar);
  }

  void _select(String url) {
    setState(() => _selectedAvatar = url);
    widget.onAvatarSelected(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Large preview
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              border: Border.all(color: NeuralColors.teal, width: 1.5),
              color: NeuralColors.teal.withValues(alpha: 0.05),
              boxShadow: [
                BoxShadow(
                  color: NeuralColors.teal.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.network(
              _selectedAvatar,
              placeholderBuilder: (_) => Center(
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
        ),

        const SizedBox(height: 14),

        // Avatar grid
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  border: .all(
                    color: selected ? NeuralColors.teal : NeuralColors.tealDark,
                    width: selected ? 2 : 1,
                  ),
                  color: selected
                      ? NeuralColors.teal.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                padding: const .all(4),
                child: SvgPicture.network(
                  url,
                  placeholderBuilder: (_) => const SizedBox(),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Refresh button
        ElevatedButton.icon(
          onPressed: _refresh,
          icon: Icon(Icons.refresh, color: NeuralColors.tealDim, size: 16),
          label: Text(
            'Generate new avatars'.toUpperCase(),
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