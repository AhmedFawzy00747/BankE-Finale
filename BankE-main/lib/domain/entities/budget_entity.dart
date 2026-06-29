class BudgetEntity {
  final int id;
  final String category;
  final double amount;
  final double spentAmount;
  final int month;
  final int year;

  const BudgetEntity({
    required this.id,
    required this.category,
    required this.amount,
    this.spentAmount = 0.0,
    required this.month,
    required this.year,
  });
}

class BudgetProgressEntity {
  final int? id;
  final String category;
  final double limitAmount;
  final double spentAmount;
  final double percentage;
  final bool isExceeded;

  const BudgetProgressEntity({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.spentAmount,
    required this.percentage,
    required this.isExceeded,
  });
}
