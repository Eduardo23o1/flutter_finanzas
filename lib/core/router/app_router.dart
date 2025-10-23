import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_finanzas_frontend2/core/utils/constants.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/add_transaction_page.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/login_page.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/register_page.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/home_page.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/statistics_page.dart';
import 'package:prueba_tecnica_finanzas_frontend2/presentation/pages/transaction_detail_page.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GoRouter> createRouter() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(kTokenKey);

  return GoRouter(
    initialLocation: token != null ? '/home' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add-transaction',
        name: 'addTransaction',
        builder: (context, state) {
          final transactionId = state.extra as String?;
          return AddTransactionPage(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: '/transaction-detail',
        name: 'transactionDetail',
        builder: (context, state) {
          final transaction = state.extra as Transaction;
          return TransactionDetailPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
    ],
  );
}
