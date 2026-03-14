import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/providers/audio_provider.dart';

class AudioAppWrapper extends ConsumerStatefulWidget {
  const AudioAppWrapper({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AudioAppWrapper> createState() => _AudioAppWrapperState();
}

class _AudioAppWrapperState extends ConsumerState<AudioAppWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(audioEnabledProvider.notifier);
      await controller.initialize();
      await controller.ensureBackgroundMusic();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(audioEnabledProvider.notifier);

    if (state == AppLifecycleState.resumed) {
      controller.ensureBackgroundMusic();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.pauseBackgroundMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}