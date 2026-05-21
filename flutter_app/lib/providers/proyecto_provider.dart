import 'package:flutter/foundation.dart';

import '../models/proyecto.dart';
import '../services/api_client.dart';
import '../services/proyecto_service.dart';
import 'auth_provider.dart';

class ProyectoProvider extends ChangeNotifier {
  final ProyectoService _service = ProyectoService();
  AuthProvider? _auth;

  List<Proyecto> proyectos = [];
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
      proyectos = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load proyectos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String idProyecto,
    required String nombre,
    required String entidadFinanciadora,
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
        entidadFinanciadora: entidadFinanciadora,
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create proyecto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required String idProyecto,
    required String nombre,
    required String entidadFinanciadora,
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
        idProyecto: idProyecto,
        data: {
          'nombre': nombre,
          'entidad_financiadora': entidadFinanciadora,
        },
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update proyecto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String idProyecto) async {
    final token = _auth?.token;
    if (token == null) {
      error = 'Not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _service.delete(token: token, idProyecto: idProyecto);
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to delete proyecto';
      notifyListeners();
      return false;
    }
  }
}
