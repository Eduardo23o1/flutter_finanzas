import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;
  final List<Transaction> _transactions = [];

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    // Cargar transacciones automáticamente al crear el Bloc
    _loadInitialTransactions();
    on<CreateTransactionRequested>(_onCreateTransaction);
    on<UpdateTransactionRequested>(_onUpdateTransaction);
    on<FetchTransactionsRequested>(_onFetchTransactions);
    on<DeleteTransactionRequested>(_onDeleteTransaction);
    on<FetchTransactionByIdRequested>(_onFetchTransactionById);
  }

  Future<void> _loadInitialTransactions() async {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(TransactionLoading());
    try {
      final transactions = await repository.getTransactions();
      _transactions
        ..clear()
        ..addAll(transactions);
      // ignore: invalid_use_of_visible_for_testing_member
      emit(TransactionListSuccess(List.from(_transactions)));
    } catch (e) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(TransactionError('Error al cargar transacciones: $e'));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final result = await repository.createTransaction(event.transaction);
      if (result != null) {
        _transactions.insert(0, result);
        emit(TransactionCreated(result));
        emit(TransactionListSuccess(List.from(_transactions)));
      } else {
        emit(TransactionError('Error al crear la transacción'));
      }
    } catch (e) {
      emit(TransactionError('Error: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final updated = await repository.updateTransaction(event.transaction);
      if (updated != null) {
        final index = _transactions.indexWhere((tx) => tx.id == updated.id);
        if (index >= 0) {
          _transactions[index] = updated;
        } else {
          _transactions.insert(0, updated);
        }
        emit(TransactionUpdated(updated));
        emit(TransactionListSuccess(List.from(_transactions)));
      } else {
        emit(TransactionError('Error al actualizar la transacción'));
      }
    } catch (e) {
      emit(TransactionError('Error: $e'));
    }
  }

  Future<void> _onFetchTransactions(
    FetchTransactionsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await repository.getTransactions();
      _transactions
        ..clear()
        ..addAll(transactions);
      emit(TransactionListSuccess(List.from(_transactions)));
    } catch (e) {
      emit(TransactionError('Error al cargar transacciones: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final success = await repository.deleteTransaction(event.transactionId);
      if (success) {
        _transactions.removeWhere((tx) => tx.id == event.transactionId);
        emit(TransactionDeleted(event.transactionId));
        emit(TransactionListSuccess(List.from(_transactions)));
      } else {
        emit(TransactionError('No se pudo eliminar la transacción'));
      }
    } catch (e) {
      emit(TransactionError('Error: $e'));
    }
  }

  Future<void> _onFetchTransactionById(
    FetchTransactionByIdRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final tx = await repository.getTransactionById(event.id);
      if (tx != null) {
        emit(TransactionLoaded(tx));
      } else {
        emit(TransactionError('Transacción no encontrada'));
      }
    } catch (e) {
      emit(TransactionError('Error: $e'));
    }
  }
}
