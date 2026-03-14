import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/providers/audio_provider.dart';

class AudioToggleButton extends ConsumerWidget {
  const AudioToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(audioEnabledProvider);

    return IconButton(
      tooltip: enabled ? 'Mute audio' : 'Unmute audio',
      onPressed: () async {
        await ref.read(audioEnabledProvider.notifier).toggle();
      },
      icon: Icon(
        enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        color: enabled ? NeuralColors.teal : NeuralColors.tealDim,
      ),
    );
  }
}