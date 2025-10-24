import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';
import '../../domain/models/transaction.dart';
import '../blocs/statistics/statistics_bloc.dart';
import '../widgets/custom_back_header.dart';
import '../widgets/choice_chip_selector.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/totals_card.dart';
import '../widgets/statistics_chart.dart';
import '../../core/di/injection.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => StatisticsBloc(repository: sl())..add(
            LoadStatistics(category: 'Todas', startDate: null, endDate: null),
          ),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatefulWidget {
  const _StatisticsView();

  @override
  State<_StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<_StatisticsView> {
  String selectedCategory = 'Todas';
  DateTimeRange? selectedDateRange;
  String selectedType = 'Ambos';
  String selectedChart = 'Barras';

  final categories = {
    'Todas': 'Todas',
    for (var entry in transactionCategoryTranslations.entries)
      entry.key.name: entry.value,
  };

  final List<Color> pieColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];

  void _loadStatistics() {
    context.read<StatisticsBloc>().add(
      LoadStatistics(
        category: selectedCategory,
        startDate: selectedDateRange?.start,
        endDate: selectedDateRange?.end,
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (selectedType == 'Ingresos') {
      return transactions
          .where((t) => t.type == TransactionType.income)
          .toList();
    } else if (selectedType == 'Gastos') {
      return transactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
    }
    return transactions;
  }

  int _sumByType(List<Transaction> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0, (sum, t) => sum + t.amount.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomBackHeader(
              text: "Estadísticas",
              backgroundColor: Colors.blueAccent,
              iconColor: Colors.black,
              textColor: Colors.black,
              onBack: () => context.go('/home'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChoiceChipSelector(
                      options: categories.values.toList(),
                      selectedValue: categories[selectedCategory]!,
                      onSelected: (selectedLabel) {
                        final matchedKey =
                            categories.entries
                                .firstWhere(
                                  (entry) => entry.value == selectedLabel,
                                )
                                .key;
                        setState(() {
                          selectedCategory = matchedKey;
                          _loadStatistics();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ChoiceChipSelector(
                      options: ['Ambos', 'Ingresos', 'Gastos'],
                      selectedValue: selectedType,
                      onSelected: (type) {
                        setState(() {
                          selectedType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DateRangeSelector(
                      selectedRange: selectedDateRange,
                      onRangeSelected: (range) {
                        setState(() {
                          selectedDateRange = range;
                          _loadStatistics();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ChoiceChipSelector(
                      options: ['Barras', 'Pastel'],
                      selectedValue: selectedChart,
                      onSelected: (chart) {
                        setState(() {
                          selectedChart = chart;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<StatisticsBloc, StatisticsState>(
                      builder: (context, state) {
                        if (state is StatisticsLoaded) {
                          final filtered = _filterTransactions(
                            state.transactions,
                          );
                          final totalIncome = _sumByType(
                            filtered,
                            TransactionType.income,
                          );
                          final totalExpense = _sumByType(
                            filtered,
                            TransactionType.expense,
                          );
                          return TotalsCard(
                            totalIncome: totalIncome,
                            totalExpense: totalExpense,
                            currencyFormatter: currencyFormatter,
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: BlocBuilder<StatisticsBloc, StatisticsState>(
                        builder: (context, state) {
                          if (state is StatisticsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is StatisticsLoaded) {
                            final filtered = _filterTransactions(
                              state.transactions,
                            );
                            return StatisticsChart(
                              transactions: filtered,
                              selectedType: selectedType,
                              selectedChart: selectedChart,
                              categories: categories,
                              pieColors: pieColors,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
