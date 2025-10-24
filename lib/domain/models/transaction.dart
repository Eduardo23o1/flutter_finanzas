import 'transaction_enums.dart';

class Transaction {
  final String? id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final String description;
  final DateTime date;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  }) {
    // Validación automática: la categoría debe coincidir con el tipo
    if (category.type != type && category != TransactionCategory.other) {
      throw Exception(
        'La categoría "${category.name}" no coincide con el tipo "${type.name}"',
      );
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final type = TransactionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => TransactionType.expense,
    );

    final category = TransactionCategory.fromName(json['category']);

    return Transaction(
      id: json['_id'] ?? json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      type: type,
      category: category,
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Obtener traducción de categoría
  String get categoryTranslation =>
      transactionCategoryTranslations[category.name] ?? category.name;

  // Obtener traducción de tipo
  String get typeTranslation => transactionTypeTranslations[type] ?? type.name;
}
