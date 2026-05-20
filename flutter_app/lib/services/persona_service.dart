import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/persona.dart';
import 'api_client.dart';

class PersonaService {
  Future<List<Persona>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/personas/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch personas');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Persona.fromJson(item as Map<String, dynamic>)).toList();
  }
}
