import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/readme_draft.dart';
import 'api_client.dart';

class ReadmeService {
  Future<List<ReadmeRepositoryOption>> listRepositories({
    required String token,
    required String owner,
    required String kind,
  }) async {
    final uri = Uri.parse('${AppConfig.readmeApiBaseUrl}/repos').replace(queryParameters: {
      'owner': owner,
      'kind': kind,
    });
    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    _ensureSuccess(response, expectedStatusCodes: const [200], fallback: 'No fue posible cargar los repositorios');

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ReadmeRepositoryOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ReadmeDocument> getReadme({
    required String token,
    required String owner,
    required String repo,
    String path = 'README.md',
  }) async {
    final uri = Uri.parse('${AppConfig.readmeApiBaseUrl}/repos/$owner/$repo/readme').replace(
      queryParameters: {
        'path': path.trim().isEmpty ? 'README.md' : path.trim(),
      },
    );
    final response = await http.get(uri, headers: _headers(token));

    _ensureSuccess(response, expectedStatusCodes: const [200], fallback: 'No fue posible cargar el README');
    return ReadmeDocument.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> getTemplate() async {
    final uri = Uri.parse('${AppConfig.readmeApiBaseUrl}/readme/template');
    final response = await http.get(uri);

    _ensureSuccess(response, expectedStatusCodes: const [200], fallback: 'No fue posible cargar la plantilla');
    return response.body;
  }

  Future<String> generate({required ReadmeDraft draft}) async {
    final uri = Uri.parse('${AppConfig.readmeApiBaseUrl}/readme/generate');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(draft.toGeneratePayload()),
    );

    _ensureSuccess(response, expectedStatusCodes: const [200], fallback: 'No fue posible generar el README');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['markdown'] as String? ?? '';
  }

  Future<void> publish({
    required String token,
    required String owner,
    required String repo,
    required String markdown,
    required String commitMessage,
    required String path,
    String? branch,
  }) async {
    final uri = Uri.parse('${AppConfig.readmeApiBaseUrl}/repos/$owner/$repo/readme');
    final body = <String, dynamic>{
      'markdown': markdown,
      'commit_message': commitMessage,
      'path': path.trim().isEmpty ? 'README.md' : path.trim(),
      if (branch != null && branch.trim().isNotEmpty) 'branch': branch.trim(),
    };

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    _ensureSuccess(response, expectedStatusCodes: const [200], fallback: 'No fue posible publicar el README');
  }

  Future<ReadmeRepositoryOption> createRepository({
    required String token,
    required String owner,
    required String kind,
    required String name,
    bool private = true,
    String? description,
  }) async {
    final uri = Uri.parse('${AppConfig.readmeApiBaseUrl}/repos');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'owner': owner,
        'kind': kind,
        'name': name,
        'private': private,
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        'auto_init': true,
      }),
    );

    _ensureSuccess(response, expectedStatusCodes: const [200, 201], fallback: 'No fue posible crear el repositorio');
    return ReadmeRepositoryOption.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Map<String, String> _headers(String token) {
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }

  void _ensureSuccess(
    http.Response response, {
    required List<int> expectedStatusCodes,
    required String fallback,
  }) {
    if (expectedStatusCodes.contains(response.statusCode)) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    throw ApiException(_extractError(response.body, fallback));
  }

  String _extractError(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {
      // Ignore JSON parsing errors and fall back to a generic message.
    }

    return body.trim().isNotEmpty ? body.trim() : fallback;
  }
}
