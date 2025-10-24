import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/transaction/transaction_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeServices();

  final GoRouter router = await createRouter();

  runApp(MyApp(router: router));
}

Future<void> _initializeServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('es_CO', null);

  // Inicializar inyección de dependencias
  await initInjection(initialToken: null);
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository: sl<AuthRepository>()),
        ),
        BlocProvider(
          create:
              (_) => TransactionBloc(repository: sl<TransactionRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Finanzas App',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      ),
    );
  }
}
