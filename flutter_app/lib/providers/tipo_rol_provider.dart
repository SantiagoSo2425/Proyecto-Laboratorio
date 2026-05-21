import 'package:flutter/foundation.dart';

import '../models/tipo_rol.dart';
import '../services/api_client.dart';
import '../services/tipo_rol_service.dart';
import 'auth_provider.dart';

class TipoRolProvider extends ChangeNotifier {
  final TipoRolService _service = TipoRolService();
  AuthProvider? _auth;

  List<TipoRol> tipos = [];
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
      tipos = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load tipos de rol';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String nombre) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.create(token: token, nombre: nombre);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create tipo de rol';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int idTipo, String nombre) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.update(token: token, idTipo: idTipo, nombre: nombre);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update tipo de rol';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int idTipo) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, idTipo: idTipo);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete tipo de rol';
      notifyListeners();
      return false;
    }
  }
}
