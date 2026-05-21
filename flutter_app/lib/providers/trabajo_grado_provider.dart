import 'package:flutter/foundation.dart';

import '../models/trabajo_grado.dart';
import '../services/api_client.dart';
import '../services/trabajo_grado_service.dart';
import 'auth_provider.dart';

class TrabajoGradoProvider extends ChangeNotifier {
  final TrabajoGradoService _service = TrabajoGradoService();
  AuthProvider? _auth;

  List<TrabajoGrado> trabajos = [];
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
      trabajos = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load trabajos de grado';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String idProyecto,
    required String nombre,
    required String facultad,
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
        idProyecto: idProyecto,
        nombre: nombre,
        facultad: facultad,
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create trabajo de grado';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int idTrabajo,
    required String idProyecto,
    required String nombre,
    required String facultad,
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
        idTrabajo: idTrabajo,
        data: {
          'id_proyecto': idProyecto,
          'nombre': nombre,
          'facultad': facultad,
        },
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update trabajo de grado';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int idTrabajo) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, idTrabajo: idTrabajo);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete trabajo de grado';
      notifyListeners();
      return false;
    }
  }
}
