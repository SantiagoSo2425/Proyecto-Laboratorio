import 'package:flutter/foundation.dart';

import '../models/persona.dart';
import '../services/api_client.dart';
import '../services/persona_service.dart';
import 'auth_provider.dart';

class PersonaProvider extends ChangeNotifier {
  final PersonaService _service = PersonaService();
  AuthProvider? _auth;

  List<Persona> personas = [];
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
      personas = await _service.list(token: token);
    } on UnauthorizedException {
      error = 'Session expired. Please login again.';
      await _auth?.logout();
    } catch (_) {
      error = 'Failed to load personas';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
