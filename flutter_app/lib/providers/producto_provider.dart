import 'package:flutter/foundation.dart';

import '../models/producto.dart';
import '../services/api_client.dart';
import '../services/producto_service.dart';
import 'auth_provider.dart';

class ProductoProvider extends ChangeNotifier {
  final ProductoService _service = ProductoService();
  AuthProvider? _auth;

  List<Producto> productos = [];
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
      productos = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load productos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String descripcion) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.create(token: token, descripcion: descripcion);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create producto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int idProducto, String descripcion) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.update(token: token, idProducto: idProducto, descripcion: descripcion);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update producto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int idProducto) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, idProducto: idProducto);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete producto';
      notifyListeners();
      return false;
    }
  }
}
