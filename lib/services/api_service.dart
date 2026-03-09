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

  // dicebear avatar bots generation

  static List<String> generateAvatarOptions({int count = 6}) {
    final rng = Random();
    return List.generate(count, (_) {
      final seed = rng.nextInt(99999).toString();
      return 'https://api.dicebear.com/9.x/bottts/svg?seed=$seed&backgroundColor=0a0a0f';
    });
  }

  // authentication

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
    };
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
}
