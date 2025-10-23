import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange> onRangeSelected;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(
        selectedRange == null
            ? 'Seleccionar fecha'
            : '${DateFormat('dd/MM/yyyy').format(selectedRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}',
      ),
      onPressed: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2022),
          lastDate: DateTime.now(),
        );
        if (range != null) {
          onRangeSelected(range);
        }
      },
    );
  }
}
