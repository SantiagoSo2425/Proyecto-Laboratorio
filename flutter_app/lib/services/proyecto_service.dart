import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/proyecto.dart';
import 'api_client.dart';

class ProyectoService {
  Future<List<Proyecto>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyectos/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch proyectos');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Proyecto.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Proyecto> create({
    required String token,
    required String idProyecto,
    required String codigoProyecto,
    required String nombre,
    required String entidadFinanciadora,
    required String tipo,
    required List<int> institucionIds,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyectos/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_proyecto': idProyecto,
        'codigo_proyecto': codigoProyecto,
        'nombre': nombre,
        'entidad_financiadora': entidadFinanciadora,
        'tipo': tipo,
        'institucion_ids': institucionIds,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create proyecto');
    }

    return Proyecto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Proyecto> update({
    required String token,
    required String idProyecto,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyectos/$idProyecto');
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
      throw ApiException('Failed to update proyecto');
    }

    return Proyecto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required String idProyecto}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyectos/$idProyecto');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete proyecto');
    }
  }
}
