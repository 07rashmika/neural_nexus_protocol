// import 'package:http/http.dart' as http;

// class ServerConfig {
//   static String? _resolvedBase;

//   static String get base {
//     assert(_resolvedBase != null, 'Call ServerConfig.resolve() before using base');
//     return _resolvedBase!;
//   }

//   static Future<void> resolve() async {
//     if (_resolvedBase != null) return;

//     final candidates = [
//       'http://10.0.2.2:3000',        // Android emulator
//       'http://127.0.0.1:3000',       // iOS simulator
//       ..._subnet('192.168.1'),
//       ..._subnet('192.168.0'),
//       ..._subnet('10.0.0'),
//     ];

//     for (final host in candidates) {
//       try {
//         final res = await http
//             .get(Uri.parse('$host/health'))
//             .timeout(const Duration(seconds: 1));
//         if (res.statusCode == 200) {
//           _resolvedBase = '$host/api';
//           print('[ServerConfig] Found backend at $host');
//           return;
//         }
//       } catch (_) {}
//     }

//     _resolvedBase = 'http://localhost:3000/api';
//     print('[ServerConfig] WARNING: backend not found, using fallback');
//   }

//   static void reset() => _resolvedBase = null;

//   static List<String> _subnet(String prefix) =>
//       List.generate(20, (i) => 'http://$prefix.${i + 1}:3000');
// }