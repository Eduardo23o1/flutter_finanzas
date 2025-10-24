import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';
import '../../core/di/injection.dart';
import '../blocs/statistics/statistics_bloc.dart';
import '../widgets/custom_back_header.dart';
import '../widgets/choice_chip_selector.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/totals_card.dart';
import '../widgets/statistics_chart.dart';

extension TransactionListExtension on List<Transaction> {
  List<Transaction> filterByType(String type) {
    if (type == 'Ingresos') {
      return where((t) => t.type == TransactionType.income).toList();
    } else if (type == 'Gastos') {
      return where((t) => t.type == TransactionType.expense).toList();
    }
    return this;
  }

  int sumByType(TransactionType type) =>
      where((t) => t.type == type).fold(0, (sum, t) => sum + t.amount.toInt());
}

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

  /// Mapa completo de todas las categorías
  Map<String, String> get allCategories => {
    'Todas': 'Todas',
    for (var c in TransactionCategory.all)
      c.name: transactionCategoryTranslations[c.name]!,
  };

  /// Filtrar categorías según tipo seleccionado
  Map<String, String> get filteredCategories {
    if (selectedType == 'Ingresos') {
      return {
        'Todas': 'Todas',
        for (var c in TransactionCategory.incomeCategories)
          c.name: transactionCategoryTranslations[c.name]!,
      };
    } else if (selectedType == 'Gastos') {
      return {
        'Todas': 'Todas',
        for (var c in TransactionCategory.expenseCategories)
          c.name: transactionCategoryTranslations[c.name]!,
      };
    }
    return allCategories;
  }

  void _updateFilters() {
    context.read<StatisticsBloc>().add(
      LoadStatistics(
        category: selectedCategory,
        startDate: selectedDateRange?.start,
        endDate: selectedDateRange?.end,
      ),
    );
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
                    /// Tipo de transacción
                    ChoiceChipSelector(
                      options: ['Ambos', 'Ingresos', 'Gastos'],
                      selectedValue: selectedType,
                      onSelected: (type) {
                        setState(() {
                          selectedType = type;

                          // Resetear la categoría al cambiar tipo
                          selectedCategory = 'Todas';

                          _updateFilters();
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    /// Categoría filtrada por tipo
                    ChoiceChipSelector(
                      options: filteredCategories.values.toList(),
                      selectedValue: filteredCategories[selectedCategory]!,
                      onSelected: (selectedLabel) {
                        final matchedKey =
                            filteredCategories.entries
                                .firstWhere(
                                  (entry) => entry.value == selectedLabel,
                                )
                                .key;
                        setState(() {
                          selectedCategory = matchedKey;
                          _updateFilters();
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    /// Selector de fechas
                    DateRangeSelector(
                      selectedRange: selectedDateRange,
                      onRangeSelected: (range) {
                        setState(() {
                          selectedDateRange = range;
                          _updateFilters();
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    /// Tipo de gráfico
                    ChoiceChipSelector(
                      options: ['Barras', 'Pastel'],
                      selectedValue: selectedChart,
                      onSelected: (chart) {
                        setState(() => selectedChart = chart);
                      },
                    ),
                    const SizedBox(height: 16),

                    BlocBuilder<StatisticsBloc, StatisticsState>(
                      builder: (context, state) {
                        if (state is StatisticsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is StatisticsLoaded) {
                          // Filtrar por tipo seleccionado
                          final filtered = state.transactions.filterByType(
                            selectedType,
                          );

                          final totalIncome = filtered.sumByType(
                            TransactionType.income,
                          );
                          final totalExpense = filtered.sumByType(
                            TransactionType.expense,
                          );

                          return Column(
                            children: [
                              TotalsCard(
                                totalIncome: totalIncome,
                                totalExpense: totalExpense,
                                currencyFormatter: currencyFormatter,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 400,
                                child: StatisticsChart(
                                  transactions: filtered,
                                  selectedType: selectedType,
                                  selectedChart: selectedChart,
                                  categories: filteredCategories,
                                  pieColors: pieColors,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
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
