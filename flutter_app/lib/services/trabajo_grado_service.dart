import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/trabajo_grado.dart';
import 'api_client.dart';

class TrabajoGradoService {
  Future<List<TrabajoGrado>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajos-grado/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch trabajos de grado');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => TrabajoGrado.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TrabajoGrado> create({
    required String token,
    required String idProyecto,
    required String nombre,
    required String facultad,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajos-grado/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_proyecto': idProyecto,
        'nombre': nombre,
        'facultad': facultad,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create trabajo de grado');
    }

    return TrabajoGrado.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TrabajoGrado> update({
    required String token,
    required int idTrabajo,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajos-grado/$idTrabajo');
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
      throw ApiException('Failed to update trabajo de grado');
    }

    return TrabajoGrado.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int idTrabajo}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/trabajos-grado/$idTrabajo');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete trabajo de grado');
    }
  }
}
