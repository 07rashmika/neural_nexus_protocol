// import 'dart:convert';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:http/http.dart' as http;

// /// Searches Freesound API for each sound type on init,
// /// caches the preview MP3 URLs, and plays them on demand.
// ///
// /// Add to pubspec.yaml:
// ///   audioplayers: ^6.0.0
// ///
// /// Replace 'YOUR_FREESOUND_API_KEY' with your key from freesound.org/apiv2/apply

// class SoundService {
//   SoundService._();
//   static final SoundService instance = SoundService._();

//   static const String _apiKey = String.fromEnvironment('FREESOUND_API_KEY');
//   static const String _base = 'https://freesound.org/apiv2';

//   // ── Players ───────────────────────────────────────────────────────
//   final AudioPlayer _sfxPlayer = AudioPlayer();
//   final AudioPlayer _bgPlayer = AudioPlayer();

//   // ── Cached preview URLs ───────────────────────────────────────────
//   final Map<SoundType, String?> _urls = {};

//   bool _muted = false;
//   bool _bgMuted = false;
//   bool _initialised = false;

//   // ── Search queries per sound type ─────────────────────────────────
//   static const Map<SoundType, String> _queries = {
//     SoundType.correct: 'correct answer chime short',
//     SoundType.wrong: 'error buzz short game',
//     SoundType.chainUp: 'level up power short electronic',
//     SoundType.nodeComplete: 'success fanfare short game',
//     SoundType.nodeFail: 'game over fail short',
//     SoundType.dailyComplete: 'victory complete game short',
//     SoundType.bgMusic: 'cyberpunk ambient electronic loop',
//   };

//   // ── Init — call once from main.dart or HomeScreen.initState ───────

//   Future<void> init() async {
//     if (_initialised) return;
//     _initialised = true;

//     await Future.wait(SoundType.values.map((type) => _fetchUrl(type)));

//     await _bgPlayer.setReleaseMode(ReleaseMode.loop);
//     await _bgPlayer.setVolume(0.25);
//     await _sfxPlayer.setVolume(0.8);

//     _playBg();
//   }

//   Future<void> _fetchUrl(SoundType type) async {
//     try {
//       final query = Uri.encodeComponent(_queries[type]!);
//       final filter = type == SoundType.bgMusic
//           ? '&filter=duration:[30 TO 120]'
//           : '&filter=duration:[0.2 TO 4]';
//       final uri = Uri.parse(
//         '$_base/search/text/?query=$query$filter'
//         '&fields=previews&page_size=1&sort=rating_desc'
//         '&token=$_apiKey',
//       );

//       final res = await http.get(uri);
//       if (res.statusCode != 200) return;

//       final body = jsonDecode(res.body) as Map<String, dynamic>;
//       final results = body['results'] as List?;
//       if (results == null || results.isEmpty) return;

//       final previews = results[0]['previews'] as Map<String, dynamic>?;
//       final url =
//           previews?['preview-hq-mp3'] as String? ??
//           previews?['preview-lq-mp3'] as String?;

//       _urls[type] = url;
//     } catch (_) {
//       // Silently fail — sounds are non-critical
//     }
//   }

//   // ── Playback ──────────────────────────────────────────────────────

//   Future<void> play(SoundType type) async {
//     if (_muted) return;
//     final url = _urls[type];
//     if (url == null) return;
//     try {
//       await _sfxPlayer.stop();
//       await _sfxPlayer.play(UrlSource(url));
//     } catch (_) {}
//   }

//   Future<void> _playBg() async {
//     if (_bgMuted) return;
//     final url = _urls[SoundType.bgMusic];
//     if (url == null) return;
//     try {
//       await _bgPlayer.play(UrlSource(url));
//     } catch (_) {}
//   }

//   // ── Controls ──────────────────────────────────────────────────────

//   void toggleMute() {
//     _muted = !_muted;
//   }

//   void toggleBgMusic() {
//     _bgMuted = !_bgMuted;
//     if (_bgMuted) {
//       _bgPlayer.pause();
//     } else {
//       _playBg();
//     }
//   }

//   bool get isMuted => _muted;
//   bool get isBgMuted => _bgMuted;

//   void pauseBg() => _bgPlayer.pause();
//   void resumeBg() {
//     if (!_bgMuted) _bgPlayer.resume();
//   }

//   Future<void> dispose() async {
//     await _sfxPlayer.dispose();
//     await _bgPlayer.dispose();
//   }
// }

// enum SoundType {
//   correct,
//   wrong,
//   chainUp,
//   nodeComplete,
//   nodeFail,
//   dailyComplete,
//   bgMusic,
// }
