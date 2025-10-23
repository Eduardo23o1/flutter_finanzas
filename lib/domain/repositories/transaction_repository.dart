import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<Transaction?> createTransaction(Transaction transaction);
  Future<List<Transaction>> getTransactions();
  Future<Transaction?> updateTransaction(Transaction transaction);
  Future<Transaction?> getTransactionById(String id); // <-- nuevo
  Future<bool> deleteTransaction(String id);
}
