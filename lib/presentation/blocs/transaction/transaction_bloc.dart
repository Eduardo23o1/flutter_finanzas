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
    // Crear transacción
    on<CreateTransactionRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final result = await repository.createTransaction(event.transaction);
        if (result != null) {
          _transactions.insert(0, result);
          emit(TransactionCreated(result));
        } else {
          emit(TransactionError('Error al crear la transacción'));
        }
      } catch (e) {
        emit(TransactionError('Error: $e'));
      }
    });

    // Actualizar transacción
    on<UpdateTransactionRequested>((event, emit) async {
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
        } else {
          emit(TransactionError('Error al actualizar la transacción'));
        }
      } catch (e) {
        emit(TransactionError('Error: $e'));
      }
    });

    // Listar transacciones
    on<FetchTransactionsRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await repository.getTransactions();
        _transactions
          ..clear()
          ..addAll(transactions);
        emit(TransactionListSuccess(List.from(_transactions)));
      } catch (e) {
        emit(TransactionError('Error al cargar transacciones'));
      }
    });

    // Eliminar transacción
    on<DeleteTransactionRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        // ignore: unused_local_variable
        final success = await repository.deleteTransaction(event.transactionId);
        _transactions.removeWhere((tx) => tx.id == event.transactionId);
        emit(TransactionDeleted(event.transactionId));
      } catch (e) {
        emit(TransactionError('Error: $e'));
      }
    });

    // Obtener por ID
    on<FetchTransactionByIdRequested>((event, emit) async {
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
    });
  }
}
