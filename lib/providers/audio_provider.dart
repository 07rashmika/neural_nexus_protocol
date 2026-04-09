import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';

final audioServiceProvider = Provider<AppAudioService>((ref) {
  return AppAudioService.instance;
});

final audioEnabledProvider = StateNotifierProvider<AudioController, bool>((
  ref,
) {
  return AudioController(ref.read(audioServiceProvider));
});

class AudioController extends StateNotifier<bool> {
  AudioController(this._audioService) : super(_audioService.isAudioEnabled);

  final AppAudioService _audioService;

  Future<void> initialize() async {
    await _audioService.initialize();
    state = _audioService.isAudioEnabled;
  }

  Future<void> enableAudio() async {
    await _audioService.setMuted(false);
    state = true;
  }

  Future<void> disableAudio() async {
    await _audioService.setMuted(true);
    state = false;
  }

  Future<void> toggle() async {
    await _audioService.toggleMute();
    state = _audioService.isAudioEnabled;
  }

  Future<void> ensureBackgroundMusic() async {
    if (!state) return;
    await _audioService.ensureBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    await _audioService.pauseBackgroundMusic();
  }

  Future<void> playButtonTap() async {
    if (!state) return;
    await _audioService.playButtonTap();
  }

  Future<void> playSoftTap() async {
    if (!state) return;
    await _audioService.playSoftTap();
  }
}
