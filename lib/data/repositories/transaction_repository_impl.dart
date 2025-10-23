import 'dart:convert';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/api/api_client.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final ApiClient apiClient;

  TransactionRepositoryImpl({required this.apiClient});

  @override
  Future<Transaction?> createTransaction(Transaction transaction) async {
    final response = await apiClient.post(
      '/transactions/',
      transaction.toJson(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Transaction.fromJson(data);
    } else {
      print(
        'Error creando transacción: ${response.statusCode} -> ${response.body}',
      );
      return null;
    }
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final response = await apiClient.get('/transactions/');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      print(
        'Error obteniendo transacciones: ${response.statusCode} -> ${response.body}',
      );
      return [];
    }
  }

  @override
  Future<Transaction?> updateTransaction(Transaction transaction) async {
    final response = await apiClient.put(
      '/transactions/${transaction.id}', // <-- id de la transacción
      transaction.toJson(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Transaction.fromJson(data);
    } else {
      print(
        'Error actualizando transacción: ${response.statusCode} -> ${response.body}',
      );
      return null;
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final response = await apiClient.get('/transactions/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Transaction.fromJson(data);
    } else {
      print(
        'Error creando transacción: ${response.statusCode} -> ${response.body}',
      );
      return null;
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    final response = await apiClient.delete('/transactions/$id');
    return response.statusCode == 200;
  }
}
