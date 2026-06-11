import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/institucion.dart';
import 'api_client.dart';

class InstitucionService {
  Future<List<Institucion>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/instituciones/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch instituciones');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Institucion.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Institucion> create({required String token, required String nombre}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/instituciones/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'nombre': nombre}),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create institucion');
    }

    return Institucion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Institucion> update({required String token, required int idInstitucion, required String nombre}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/instituciones/$idInstitucion');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'nombre': nombre}),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to update institucion');
    }

    return Institucion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int idInstitucion}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/instituciones/$idInstitucion');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete institucion');
    }
  }
}
