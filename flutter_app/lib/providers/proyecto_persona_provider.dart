import 'package:flutter/foundation.dart';

import '../models/proyecto_persona.dart';
import '../services/api_client.dart';
import '../services/proyecto_persona_service.dart';
import 'auth_provider.dart';

class ProyectoPersonaProvider extends ChangeNotifier {
  final ProyectoPersonaService _service = ProyectoPersonaService();
  AuthProvider? _auth;

  List<ProyectoPersona> relaciones = [];
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
      error = 'Failed to load proyecto personas';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String idProyecto,
    required int personaId,
    required int idRol,
    required int horasSemanales,
    required DateTime fechaInicio,
    DateTime? fechaFin,
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
        personaId: personaId,
        idRol: idRol,
        horasSemanales: horasSemanales,
        fechaInicio: _formatDate(fechaInicio),
        fechaFin: fechaFin == null ? null : _formatDate(fechaFin),
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to create proyecto persona';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required String idProyecto,
    required int personaId,
    required int idRol,
    required int horasSemanales,
    required DateTime fechaInicio,
    DateTime? fechaFin,
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
          'persona_id': personaId,
          'id_rol': idRol,
          'horas_semanales': horasSemanales,
          'fecha_inicio': _formatDate(fechaInicio),
          'fecha_fin': fechaFin == null ? null : _formatDate(fechaFin),
        },
      );
      await load();
      return true;
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
      return false;
    } catch (_) {
      error = 'Failed to update proyecto persona';
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
      error = 'Failed to delete proyecto persona';
      notifyListeners();
      return false;
    }
  }

  String _formatDate(DateTime value) => value.toIso8601String().split('T').first;
}
