import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/repositories/transaction_repository.dart';
import 'package:equatable/equatable.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final TransactionRepository repository;

  StatisticsBloc({required this.repository}) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());
    try {
      final allTransactions = await repository.getTransactions();

      // Aplicar filtros
      final filtered =
          allTransactions.where((t) {
            final matchesCategory =
                event.category == 'Todas' ||
                t.category.name == event.category.toLowerCase();
            final matchesDate =
                (event.startDate == null || t.date.isAfter(event.startDate!)) &&
                (event.endDate == null || t.date.isBefore(event.endDate!));
            return matchesCategory && matchesDate;
          }).toList();

      emit(StatisticsLoaded(transactions: filtered));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}
