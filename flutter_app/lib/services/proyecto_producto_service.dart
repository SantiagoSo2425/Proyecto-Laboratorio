import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/proyecto_producto.dart';
import 'api_client.dart';

class ProyectoProductoService {
  Future<List<ProyectoProducto>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-productos/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch proyecto productos');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ProyectoProducto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProyectoProducto> create({
    required String token,
    required String idProyecto,
    required int idProducto,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-productos/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_proyecto': idProyecto,
        'id_producto': idProducto,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create proyecto producto');
    }

    return ProyectoProducto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ProyectoProducto> update({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-productos/$id');
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
      throw ApiException('Failed to update proyecto producto');
    }

    return ProyectoProducto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/proyecto-productos/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete proyecto producto');
    }
  }
}
