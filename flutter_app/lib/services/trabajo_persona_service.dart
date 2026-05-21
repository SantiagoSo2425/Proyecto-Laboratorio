import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/trabajo_persona.dart';
import 'api_client.dart';

class TrabajoPersonaService {
  Future<List<TrabajoPersona>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajo-personas/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch trabajo personas');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => TrabajoPersona.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TrabajoPersona> create({
    required String token,
    required int idTrabajo,
    required int idPersona,
    required int idRol,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajo-personas/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_trabajo': idTrabajo,
        'id_persona': idPersona,
        'id_rol': idRol,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create trabajo persona');
    }

    return TrabajoPersona.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TrabajoPersona> update({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajo-personas/$id');
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
      throw ApiException('Failed to update trabajo persona');
    }

    return TrabajoPersona.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajo-personas/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete trabajo persona');
    }
  }
}
