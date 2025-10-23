import 'dart:convert';
import 'package:prueba_tecnica_finanzas_frontend2/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<String?> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['idToken'];
      apiClient.updateToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
    }
    return null;
  }

  @override
  Future<String?> register(String email, String password) async {
    throw UnimplementedError('Registro no soportado en el backend actual');
  }
}
