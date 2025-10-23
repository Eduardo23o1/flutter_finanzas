import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/core/di/injection.dart';
import 'package:prueba_tecnica_finanzas_frontend2/core/router/app_router.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/auth_repository.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/transaction_repository.dart';
import 'package:prueba_tecnica_finanzas_frontend2/firebase_options.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_CO', null);
  await initInjection(initialToken: null);

  final GoRouter router = await createRouter();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository: sl<AuthRepository>()),
        ),
        BlocProvider(
          create:
              (_) =>
                  TransactionBloc(repository: sl<TransactionRepository>())
                    ..add(FetchTransactionsRequested()),
        ),
        BlocProvider(
          create:
              (_) => StatisticsBloc(repository: sl<TransactionRepository>()),
        ),
      ],
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finanzas App',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
