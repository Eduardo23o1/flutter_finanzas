import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_enums.dart';

class StatisticsChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String selectedType;
  final String selectedChart;
  final Map<String, String> categories;
  final List<Color> pieColors;

  const StatisticsChart({
    super.key,
    required this.transactions,
    required this.selectedType,
    required this.selectedChart,
    required this.categories,
    required this.pieColors,
  });

  List<Transaction> _filterTransactions(List<Transaction> txs) {
    if (selectedType == 'Ingresos') {
      return txs.where((t) => t.type == TransactionType.income).toList();
    } else if (selectedType == 'Gastos') {
      return txs.where((t) => t.type == TransactionType.expense).toList();
    }
    return txs;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterTransactions(transactions);
    final screenWidth = MediaQuery.of(context).size.width;

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No hay transacciones para mostrar",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Gráfico de pastel
    if (selectedChart == 'Pastel') {
      final Map<String, double> categoryTotals = {};
      double totalAmount = 0;

      for (var t in filtered) {
        final cat = categories[t.category.name] ?? t.category.name;
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + t.amount;
        totalAmount += t.amount;
      }

      final entries = categoryTotals.entries.toList();

      return SizedBox(
        height:
            screenWidth < 600
                ? 300 // móvil
                : screenWidth < 1000
                ? 400 // tablet
                : 500, // escritorio
        child: SfCircularChart(
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <PieSeries<MapEntry<String, double>, String>>[
            PieSeries<MapEntry<String, double>, String>(
              dataSource: entries,
              pointColorMapper:
                  (entry, index) => pieColors[index % pieColors.length],
              xValueMapper: (entry, _) => entry.key,
              yValueMapper: (entry, _) => entry.value,
              dataLabelMapper:
                  (entry, _) =>
                      '${entry.key}: ${(entry.value / totalAmount * 100).toStringAsFixed(0)}%',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                connectorLineSettings: ConnectorLineSettings(length: '20%'),
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    //Gráfico de barras
    final double chartWidth =
        filtered.length * 80.0 > screenWidth
            ? filtered.length * 80.0
            : screenWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        height:
            screenWidth < 600
                ? 300 // móvil
                : screenWidth < 1000
                ? 400 // tablet
                : 500, // escritorio
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(labelRotation: 45),
          primaryYAxis: NumericAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CartesianSeries>[
            if (selectedType != 'Gastos')
              StackedColumnSeries<Transaction, String>(
                dataSource: filtered,
                xValueMapper:
                    (t, _) => categories[t.category.name] ?? t.category.name,
                yValueMapper:
                    (t, _) => t.type == TransactionType.income ? t.amount : 0,
                name: 'Ingresos',
                color: Colors.greenAccent.shade700,
              ),
            if (selectedType != 'Ingresos')
              StackedColumnSeries<Transaction, String>(
                dataSource: filtered,
                xValueMapper:
                    (t, _) => categories[t.category.name] ?? t.category.name,
                yValueMapper:
                    (t, _) => t.type == TransactionType.expense ? t.amount : 0,
                name: 'Gastos',
                color: Colors.redAccent.shade400,
              ),
          ],
        ),
      ),
    );
  }
}
