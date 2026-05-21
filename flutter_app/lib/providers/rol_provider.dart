import 'package:flutter/foundation.dart';

import '../models/rol.dart';
import '../services/api_client.dart';
import '../services/rol_service.dart';
import 'auth_provider.dart';

class RolProvider extends ChangeNotifier {
  final RolService _service = RolService();
  AuthProvider? _auth;

  List<Rol> roles = [];
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
      roles = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load roles';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({required int idTipo, required String tipo}) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.create(token: token, idTipo: idTipo, tipo: tipo);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create rol';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({required int idRol, required int idTipo, required String tipo}) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.update(token: token, idRol: idRol, idTipo: idTipo, tipo: tipo);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update rol';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int idRol) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, idRol: idRol);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete rol';
      notifyListeners();
      return false;
    }
  }
}
