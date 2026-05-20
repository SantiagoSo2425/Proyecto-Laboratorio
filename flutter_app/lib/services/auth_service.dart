import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'api_client.dart';

class AuthService {
  Future<String> login({required String username, required String password}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode != 200) {
      throw ApiException('Invalid credentials');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['access_token'] as String;
  }
}
