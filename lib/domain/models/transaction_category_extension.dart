import 'package:flutter/material.dart';
import 'transaction_enums.dart';

extension TransactionCategoryExtension on TransactionCategory {
  String get label => transactionCategoryTranslations[name] ?? name;

  IconData get icon {
    switch (name) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.attach_money;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }
}
