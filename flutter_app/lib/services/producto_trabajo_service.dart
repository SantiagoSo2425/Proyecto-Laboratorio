import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/producto_trabajo.dart';
import 'api_client.dart';

class ProductoTrabajoService {
  Future<List<ProductoTrabajo>> list({required String token}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/producto-trabajos/?skip=0&limit=100');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch producto trabajos');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ProductoTrabajo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProductoTrabajo> create({
    required String token,
    required int idTrabajo,
    required int idProducto,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/producto-trabajos/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_trabajo': idTrabajo,
        'id_producto': idProducto,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 201) {
      throw ApiException('Failed to create producto trabajo');
    }

    return ProductoTrabajo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ProductoTrabajo> update({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/producto-trabajos/$id');
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
      throw ApiException('Failed to update producto trabajo');
    }

    return ProductoTrabajo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/producto-trabajos/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete producto trabajo');
    }
  }
}
