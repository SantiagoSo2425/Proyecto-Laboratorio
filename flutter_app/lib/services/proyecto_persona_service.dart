import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/proyecto_persona.dart';
import 'api_client.dart';

class ProyectoPersonaService {
  Future<List<ProyectoPersona>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-personas/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch proyecto personas');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ProyectoPersona.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProyectoPersona> create({
    required String token,
    required String idProyecto,
    required int personaId,
    required int idRol,
    required int horasSemanales,
    required String fechaInicio,
    String? fechaFin,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-personas/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_proyecto': idProyecto,
        'persona_id': personaId,
        'id_rol': idRol,
        'horas_semanales': horasSemanales,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create proyecto persona');
    }

    return ProyectoPersona.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ProyectoPersona> update({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-personas/$id');
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
      throw ApiException('Failed to update proyecto persona');
    }

    return ProyectoPersona.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-personas/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete proyecto persona');
    }
  }
}
