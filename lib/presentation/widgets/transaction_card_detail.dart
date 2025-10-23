import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_enums.dart';

class TransactionCardDetail extends StatelessWidget {
  final Transaction transaction;
  final double? maxWidth;

  const TransactionCardDetail({
    super.key,
    required this.transaction,
    this.maxWidth,
  });

  IconData getIconByCategory(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_bus;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.health:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.salary:
        return Icons.attach_money;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final mainColor = isIncome ? Colors.green[600]! : Colors.red[600]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth =
            constraints.maxWidth < 600 ? double.infinity : maxWidth ?? 500;

        return Center(
          child: Card(
            elevation: 6,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    getIconByCategory(transaction.category),
                    color: mainColor,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    transactionTypeTranslations[transaction.type] ??
                        'Desconocido',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    NumberFormat.currency(
                      locale: 'es_CO',
                      symbol: '\$',
                      decimalDigits: 0,
                    ).format(transaction.amount),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    transactionCategoryTranslations[transaction.category] ??
                        'Desconocido',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
