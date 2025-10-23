import 'package:flutter/material.dart';

class ChoiceChipSelector extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final Color selectedColor;

  const ChoiceChipSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.selectedColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Móviles y pantallas pequeñas → scroll horizontal
    if (screenWidth < 800) {
      return SizedBox(
        height: 50,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                options.map((option) {
                  final isSelected = selectedValue == option;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: selectedColor,
                      backgroundColor: Colors.grey.shade200,
                      onSelected: (_) => onSelected(option),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }

    // Tablets grandes y Web → distribución tipo grid (Wrap)
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((option) {
            final isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              selectedColor: selectedColor,
              backgroundColor: Colors.grey.shade200,
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
    );
  }
}
