part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStatistics extends StatisticsEvent {
  final String category;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadStatistics({this.category = 'Todas', this.startDate, this.endDate});

  @override
  List<Object?> get props => [category, startDate, endDate];
}
