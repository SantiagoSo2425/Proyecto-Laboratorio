import 'package:flutter/foundation.dart';

import '../models/proyecto_producto.dart';
import '../services/api_client.dart';
import '../services/proyecto_producto_service.dart';
import 'auth_provider.dart';

class ProyectoProductoProvider extends ChangeNotifier {
  final ProyectoProductoService _service = ProyectoProductoService();
  AuthProvider? _auth;

  List<ProyectoProducto> relaciones = [];
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
      error = 'Failed to load proyecto productos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String idProyecto,
    required int idProducto,
  }) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.create(token: token, idProyecto: idProyecto, idProducto: idProducto);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create proyecto producto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required String idProyecto,
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
          'id_proyecto': idProyecto,
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
      error = 'Failed to update proyecto producto';
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
      error = 'Failed to delete proyecto producto';
      notifyListeners();
      return false;
    }
  }
}
