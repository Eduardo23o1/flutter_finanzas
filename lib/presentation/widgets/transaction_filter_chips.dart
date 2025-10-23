import 'package:flutter/material.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_enums.dart';

class TransactionFilterChips extends StatelessWidget {
  final TransactionType? selectedType;
  final ValueChanged<TransactionType?> onSelected;

  const TransactionFilterChips({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: [
        FilterChip(
          label: const Text('Todos'),
          selected: selectedType == null,
          onSelected: (_) => onSelected(null),
          selectedColor: Colors.blue[100],
        ),
        FilterChip(
          label: const Text('Ingresos'),
          selected: selectedType == TransactionType.income,
          onSelected:
              (selected) =>
                  onSelected(selected ? TransactionType.income : null),
          selectedColor: Colors.green[100],
        ),
        FilterChip(
          label: const Text('Gastos'),
          selected: selectedType == TransactionType.expense,
          onSelected:
              (selected) =>
                  onSelected(selected ? TransactionType.expense : null),
          selectedColor: Colors.red[100],
        ),
      ],
    );
  }
}
