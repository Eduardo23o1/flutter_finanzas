import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? token;

  ApiClient({required this.baseUrl, this.token});

  void updateToken(String newToken) {
    token = newToken;
  }

  Future<http.Response> get(String endpoint) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final freshToken = await user.getIdToken(true);
      updateToken(freshToken!);
    }

    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url, headers: _buildHeaders());
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.put(url, headers: _buildHeaders(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.delete(url, headers: _buildHeaders());
  }

  Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
