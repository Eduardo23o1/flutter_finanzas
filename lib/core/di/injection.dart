import 'package:get_it/get_it.dart';
import 'package:prueba_tecnica_finanzas_frontend2/data/repositories/firebase_auth_repository_impl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/data/repositories/transaction_repository_impl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/transaction_repository.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/auth_repository.dart';
import '../api/api_client.dart';

final sl = GetIt.instance;

Future<void> initInjection({String? initialToken}) async {
  const String apiBaseUrl = 'http://192.168.0.23:8000';

  // ApiClient
  sl.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: apiBaseUrl));

  // Repositorio de transacciones
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Repositorio de autenticación Firebase
  sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepositoryImpl());
}
