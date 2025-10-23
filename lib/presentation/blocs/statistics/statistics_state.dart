part of 'statistics_bloc.dart';

abstract class StatisticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<Transaction> transactions;
  StatisticsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class StatisticsError extends StatisticsState {
  final String message;
  StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
