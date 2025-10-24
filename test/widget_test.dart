import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/transaction_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:prueba_tecnica_finanzas_frontend2/main.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/home_page.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  final sl = GetIt.instance;

  setUp(() {
    sl.registerLazySingleton<TransactionRepository>(
      () => MockTransactionRepository(),
    );
  });

  tearDown(() {
    sl.reset(); // Limpia el registro para el próximo test
  });

  testWidgets('HomePage loads correctly', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<TransactionBloc>(
        create:
            (_) =>
                TransactionBloc(repository: sl<TransactionRepository>())
                  ..add(FetchTransactionsRequested()),
        child: MyApp(router: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
