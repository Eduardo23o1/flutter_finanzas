enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  transport,
  entertainment,
  shopping,
  health,
  education,
  salary,
  other,
}

// Traducciones centralizadas
const transactionTypeTranslations = {
  TransactionType.income: 'Ingreso',
  TransactionType.expense: 'Gasto',
};

const transactionCategoryTranslations = {
  TransactionCategory.food: 'Comida',
  TransactionCategory.transport: 'Transporte',
  TransactionCategory.entertainment: 'Entretenimiento',
  TransactionCategory.shopping: 'Compras',
  TransactionCategory.health: 'Salud',
  TransactionCategory.education: 'Educación',
  TransactionCategory.salary: 'Salario',
  TransactionCategory.other: 'Otros',
};
