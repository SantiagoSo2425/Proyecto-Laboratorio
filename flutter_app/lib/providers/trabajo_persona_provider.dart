import 'package:flutter/foundation.dart';

import '../models/trabajo_persona.dart';
import '../services/api_client.dart';
import '../services/trabajo_persona_service.dart';
import 'auth_provider.dart';

class TrabajoPersonaProvider extends ChangeNotifier {
  final TrabajoPersonaService _service = TrabajoPersonaService();
  AuthProvider? _auth;

  List<TrabajoPersona> relaciones = [];
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
      error = 'Failed to load trabajo personas';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required int idTrabajo,
    required int idPersona,
    required int idRol,
  }) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.create(
        token: token,
        idTrabajo: idTrabajo,
        idPersona: idPersona,
        idRol: idRol,
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create trabajo persona';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required int idTrabajo,
    required int idPersona,
    required int idRol,
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
          'id_persona': idPersona,
          'id_rol': idRol,
        },
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update trabajo persona';
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
      error = 'Failed to delete trabajo persona';
      notifyListeners();
      return false;
    }
  }
}
