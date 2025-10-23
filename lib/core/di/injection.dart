import 'package:get_it/get_it.dart';
import 'package:prueba_tecnica_finanzas_frontend2/data/repositories/transaction_repository_impl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final sl = GetIt.instance;

Future<void> initInjection({String? initialToken}) async {
  const String apiBaseUrl = 'http://192.168.1.99:8000';

  final prefs = await SharedPreferences.getInstance();
  final storedToken = prefs.getString('token');

  // ApiClient
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: apiBaseUrl, token: storedToken),
  );

  // Repositorio de autenticación
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Después de registrar AuthRepository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(apiClient: sl<ApiClient>()),
  );
}
