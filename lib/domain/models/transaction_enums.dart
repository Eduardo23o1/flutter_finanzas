enum TransactionType { income, expense }

class TransactionCategory {
  final String name;
  final TransactionType type;

  const TransactionCategory._(this.name, this.type);

  static const food = TransactionCategory._('food', TransactionType.expense);
  static const transport = TransactionCategory._(
    'transport',
    TransactionType.expense,
  );
  static const entertainment = TransactionCategory._(
    'entertainment',
    TransactionType.expense,
  );
  static const shopping = TransactionCategory._(
    'shopping',
    TransactionType.expense,
  );
  static const health = TransactionCategory._(
    'health',
    TransactionType.expense,
  );
  static const education = TransactionCategory._(
    'education',
    TransactionType.expense,
  );
  static const salary = TransactionCategory._('salary', TransactionType.income);
  static const other = TransactionCategory._('other', TransactionType.expense);

  static const all = [
    food,
    transport,
    entertainment,
    shopping,
    health,
    education,
    salary,
    other,
  ];

  /// Categorías de ingresos
  static const incomeCategories = [salary];

  /// Categorías de gastos
  static const expenseCategories = [
    food,
    transport,
    entertainment,
    shopping,
    health,
    education,
    other,
  ];

  // Buscar por nombre
  static TransactionCategory fromName(String name) {
    return all.firstWhere((c) => c.name == name, orElse: () => other);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategory &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ type.hashCode;
}

const transactionTypeTranslations = {
  TransactionType.income: 'Ingreso',
  TransactionType.expense: 'Gasto',
};

const transactionCategoryTranslations = {
  'food': 'Comida',
  'transport': 'Transporte',
  'entertainment': 'Entretenimiento',
  'shopping': 'Compras',
  'health': 'Salud',
  'education': 'Educación',
  'salary': 'Salario',
  'other': 'Otros',
};
