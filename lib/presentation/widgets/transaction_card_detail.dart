import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica_finanzas_frontend2/domain/models/transaction_category_extension.dart';
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
                  // Icono de la categoría
                  Icon(transaction.category.icon, color: mainColor, size: 50),
                  const SizedBox(height: 10),

                  // Tipo de transacción
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

                  // Monto
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

                  // Nombre de la categoría
                  Text(
                    transaction.category.label,
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
