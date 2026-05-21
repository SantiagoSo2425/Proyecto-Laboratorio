import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/tipo_rol.dart';
import 'api_client.dart';

class TipoRolService {
  Future<List<TipoRol>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/tipos-rol/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch tipos de rol');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => TipoRol.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<TipoRol> create({required String token, required String nombre}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/tipos-rol/');
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
      throw ApiException('Failed to create tipo de rol');
    }

    return TipoRol.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TipoRol> update({
    required String token,
    required int idTipo,
    required String nombre,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/tipos-rol/$idTipo');
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
      throw ApiException('Failed to update tipo de rol');
    }

    return TipoRol.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int idTipo}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/tipos-rol/$idTipo');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete tipo de rol');
    }
  }
}
