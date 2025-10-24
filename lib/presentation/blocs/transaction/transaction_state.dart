part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final Transaction transaction;
  TransactionSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionListSuccess extends TransactionState {
  final List<Transaction> transactions;
  TransactionListSuccess(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionLoaded extends TransactionState {
  final Transaction transaction;
  TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionState {
  final String transactionId;
  TransactionDeleted(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class TransactionCreated extends TransactionState {
  final Transaction transaction;
  TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionState {
  final Transaction transaction;
  TransactionUpdated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
