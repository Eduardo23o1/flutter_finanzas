part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateTransactionRequested extends TransactionEvent {
  final Transaction transaction;
  CreateTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class FetchTransactionsRequested extends TransactionEvent {}

class UpdateTransactionRequested extends TransactionEvent {
  final Transaction transaction;
  UpdateTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionRequested extends TransactionEvent {
  final String transactionId;
  DeleteTransactionRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class FetchTransactionByIdRequested extends TransactionEvent {
  final String id;
  FetchTransactionByIdRequested(this.id);

  @override
  List<Object?> get props => [id];
}
