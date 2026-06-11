import 'package:flutter/foundation.dart';

import '../models/institucion.dart';
import '../services/api_client.dart';
import '../services/institucion_service.dart';
import 'auth_provider.dart';

class InstitucionProvider extends ChangeNotifier {
  final InstitucionService _service = InstitucionService();
  AuthProvider? _auth;

  List<Institucion> instituciones = [];
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
      instituciones = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load instituciones';
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
      error = 'Failed to create institucion';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int idInstitucion, String nombre) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.update(token: token, idInstitucion: idInstitucion, nombre: nombre);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update institucion';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int idInstitucion) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, idInstitucion: idInstitucion);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete institucion';
      notifyListeners();
      return false;
    }
  }
}
