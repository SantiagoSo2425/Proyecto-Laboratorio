import 'package:flutter/foundation.dart';

import '../models/contrato.dart';
import '../services/api_client.dart';
import '../services/contrato_service.dart';
import 'auth_provider.dart';

class ContratoProvider extends ChangeNotifier {
  final ContratoService _service = ContratoService();
  AuthProvider? _auth;

  List<Contrato> contratos = [];
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
      contratos = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load contratos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String idProyecto,
    required int idPersona,
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
        idPersona: idPersona,
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create contrato';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required String idProyecto,
    required int idPersona,
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
          'id_persona': idPersona,
        },
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update contrato';
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
      error = 'Failed to delete contrato';
      notifyListeners();
      return false;
    }
  }
}