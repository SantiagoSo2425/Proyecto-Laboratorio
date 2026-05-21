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

  Future<Persona> create({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/personas/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create persona');
    }

    return Persona.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Persona> update({
    required String token,
    required int idPersona,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/personas/$idPersona');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to update persona');
    }

    return Persona.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int idPersona}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/personas/$idPersona');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete persona');
    }
  }

  Future<void> changePassword({
    required String token,
    required int idPersona,
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/personas/$idPersona/password');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to change password');
    }
  }
}
