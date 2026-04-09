import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neural_nexus_protocol/models/node.dart';
import 'package:neural_nexus_protocol/models/sector.dart';

import '../models/agent.dart';

class ApiService {
  static const String _base =
      'https://nonallelic-nonrectified-matias.ngrok-free.dev/api';
  static const _storage = FlutterSecureStorage();

  //dicebear avatar bots generation
  static List<String> generateAvatarOptions({int count = 6}) {
    final rng = Random();
    return List.generate(count, (_) {
      final seed = rng.nextInt(99999).toString();
      return 'https://api.dicebear.com/9.x/bottts/svg?seed=$seed&backgroundColor=0a0a0f';
    });
  }

  //authentication
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'username': 'agent_${DateTime.now().millisecondsSinceEpoch}',
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) {
      await _storage.write(key: 'jwt', value: body['token'] as String);
    }
    return body;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await _storage.write(key: 'jwt', value: body['token'] as String);
    }
    return body;
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  // profile management
  static Future<Agent> setupProfile({
    required String username,
    required String avatarUrl,
    String? callsign,
    String? country,
  }) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_base/profile/setup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'avatarUrl': avatarUrl,
        if (callsign != null && callsign.isNotEmpty) 'callsign': callsign,
        if (country != null && country.isNotEmpty) 'country': country,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Profile setup failed');
    }
    return Agent.fromJson(
      body['player'] as Map<String, dynamic>,
      token: token!,
    );
  }

  static Future<Agent> getProfile() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_base/profile/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to load profile');
    }
    return Agent.fromJson(
      body['player'] as Map<String, dynamic>,
      token: token!,
    );
  }

  static Future<String?> getToken() => _storage.read(key: 'jwt');

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt');
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> getSectors() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_base/sectors'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to load sectors');
    }
    return {
      'sectors': (body['sectors'] as List)
          .map((s) => Sector.fromJson(s as Map<String, dynamic>))
          .toList(),
      'totalNodes': body['totalNodes'] as int,
      'completedNodes': body['completedNodes'] as int,
    };
  }

  static Future<void> updateSectorProgress({
    required String sectorCode,
    required int completedNodes,
  }) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_base/sectors/progress'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'sectorCode': sectorCode,
        'completedNodes': completedNodes,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to update progress');
    }
  }

  static Future<Map<String, dynamic>> getNodes(String sectorCode) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_base/nodes/$sectorCode'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to load nodes');
    }
    return {
      'sector': body['sector'] as Map<String, dynamic>,
      'nodes': (body['nodes'] as List)
          .map((n) => NodeModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      'carrotsRemaining': body['carrotsRemaining'] as int? ?? 3,
    };
  }

  static Future<Map<String, dynamic>> useHint({
    required String sectorCode,
  }) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_base/nodes/hint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'sectorCode': sectorCode}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Hint failed');
    }
    return body;
  }

  static Future<Map<String, dynamic>> completeNode(String nodeId) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_base/nodes/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nodeId': nodeId}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to complete node');
    }
    return body;
  }

  //Heart Puzzle
  static Future<Map<String, dynamic>> fetchHeartPuzzle() async {
    const url = 'https://marcconrad.com/uob/heart/api.php?out=json&base64=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Puzzle fetch failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> submitAnswer({
    required int round,
    required int answer,
    required bool correct,
    required int timeTaken,
    required int carrots,
    int chain = 0, // consecutive corrects BEFORE this answer
    int timeLeft = 0, // seconds remaining on timer
  }) async {
    try {
      final token = await _storage.read(key: 'jwt');
      final res = await http.post(
        Uri.parse('$_base/game/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'round': round,
          'answer': answer,
          'correct': correct,
          'time_taken': timeTaken,
          'carrots_earned': carrots,
          'chain': chain,
          'time_left': timeLeft,
        }),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] != true) return null;
      // Return full body — caller reads shieldData, intelEarned, levelUp, etc.
      return body;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> syncShields() async {
    try {
      final token = await _storage.read(key: 'jwt');
      final res = await http.get(
        Uri.parse('$_base/game/shields'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) return body;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> failNode() async {
    final token = await _storage.read(key: 'jwt');
    await http.post(
      Uri.parse('$_base/nodes/fail'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<Map<String, dynamic>> getDailyChallengeStatus() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_base/daily/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to get daily status');
    }
    return body;
  }

  static Future<void> startDailyChallenge() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_base/daily/start'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to start daily challenge');
    }
  }

  static Future<Map<String, dynamic>> completeDailyChallenge({
    required bool passed,
    required int puzzlesPassed,
  }) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.post(
      Uri.parse('$_base/daily/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'passed': passed, 'puzzlesPassed': puzzlesPassed}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to complete daily challenge');
    }
    return body;
  }

  static Future<void> updateUsername(String username) async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.patch(
      Uri.parse('$_base/profile/username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'username': username}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (!(body['success'] as bool)) {
      throw Exception(body['message'] ?? 'Failed to update username');
    }
  }

  static Future<Map<String, dynamic>> getLeaderboard() async {
    final token = await _storage.read(key: 'jwt');
    final res = await http.get(
      Uri.parse('$_base/game/leaderboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load leaderboard');
    }
    return body;
  }

  static Future<List<Map<String, String>>> fetchCountries() async {
    final res = await http.get(
      Uri.parse('https://restcountries.com/v3.1/all?fields=name,flag'),
    );
    if (res.statusCode != 200) throw Exception('Failed to load countries');
    final list = jsonDecode(res.body) as List;
    final countries = list
        .map(
          (c) => {
            'name': c['name']['common'] as String,
            'flag': c['flag'] as String,
          },
        )
        .toList();
    countries.sort((a, b) => a['name']!.compareTo(b['name']!));
    return countries;
  }
}
