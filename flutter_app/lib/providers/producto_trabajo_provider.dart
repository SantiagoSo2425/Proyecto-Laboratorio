import 'package:flutter/foundation.dart';

import '../models/producto_trabajo.dart';
import '../services/api_client.dart';
import '../services/producto_trabajo_service.dart';
import 'auth_provider.dart';

class ProductoTrabajoProvider extends ChangeNotifier {
  final ProductoTrabajoService _service = ProductoTrabajoService();
  AuthProvider? _auth;

  List<ProductoTrabajo> relaciones = [];
  bool isLoading = false;
  String? error;

  void attachAuth(AuthProvider auth) {
    _auth = auth;
  }

  Future<void> load() async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      relaciones = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load producto trabajos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required int idTrabajo,
    required int idProducto,
  }) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.create(token: token, idTrabajo: idTrabajo, idProducto: idProducto);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create producto trabajo';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required int idTrabajo,
    required int idProducto,
  }) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.update(
        token: token,
        id: id,
        data: {
          'id_trabajo': idTrabajo,
          'id_producto': idProducto,
        },
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update producto trabajo';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, id: id);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete producto trabajo';
      notifyListeners();
      return false;
    }
  }
}
