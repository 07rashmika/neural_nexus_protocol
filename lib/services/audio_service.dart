import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AppAudioService {
  AppAudioService._();

  static final AppAudioService instance = AppAudioService._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isStartingBgm = false;

  bool get isMuted => _isMuted;
  bool get isAudioEnabled => !_isMuted;

  AudioContext get _mixingContext => AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
    route: AudioContextConfigRoute.system,
    respectSilence: false,
    stayAwake: false,
  ).build();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await AudioPlayer.global.setAudioContext(_mixingContext);

      await _bgmPlayer.setAudioContext(_mixingContext);
      await _sfxPlayer.setAudioContext(_mixingContext);

      await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.4);

      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Audio init error: $e');
    }
  }

  Future<void> initialize() async {
    await init();
  }

  Future<void> startBackgroundMusic() async {
    if (_isMuted || _isStartingBgm) return;

    await init();

    try {
      if (_bgmPlayer.state == PlayerState.playing) return;

      _isStartingBgm = true;

      await _bgmPlayer.play(
        AssetSource('audio/bgm_loop.wav'),
        volume: 0.4,
        ctx: _mixingContext,
        mode: PlayerMode.mediaPlayer,
      );
    } catch (e) {
      debugPrint('BGM start error: $e');
    } finally {
      _isStartingBgm = false;
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (_isMuted) return;

    await init();

    try {
      final state = _bgmPlayer.state;

      if (state == PlayerState.playing) return;

      if (state == PlayerState.paused) {
        await _bgmPlayer.resume();
      } else {
        await startBackgroundMusic();
      }
    } catch (e) {
      debugPrint('BGM resume error: $e');
    }
  }

  Future<void> ensureBackgroundMusic() async {
    await resumeBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      if (_bgmPlayer.state == PlayerState.playing) {
        await _bgmPlayer.pause();
      }
    } catch (e) {
      debugPrint('BGM pause error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('BGM stop error: $e');
    }
  }

  Future<void> playButtonTap() async {
    if (_isMuted) return;
    await _playSfx('audio/button_click.wav');
  }

  Future<void> playSoftTap() async {
    if (_isMuted) return;
    await _playSfx('audio/button_soft.wav');
  }

  Future<void> _playSfx(String assetPath) async {
    try {
      await init();

      await _sfxPlayer.stop();
      await _sfxPlayer.play(
        AssetSource(assetPath),
        ctx: _mixingContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('SFX play error for $assetPath: $e');
    }
  }

  Future<void> setMuted(bool value) async {
    if (_isMuted == value) return;

    _isMuted = value;

    if (_isMuted) {
      await _sfxPlayer.stop();
      await pauseBackgroundMusic();
    } else {
      await ensureBackgroundMusic();
    }
  }

  Future<void> toggleMute() async {
    await setMuted(!_isMuted);
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _bgmPlayer.dispose();
  }
}
