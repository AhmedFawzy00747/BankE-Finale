import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.amount,
    super.spentAmount,
    required super.month,
    required super.year,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }
}

class BudgetProgressModel extends BudgetProgressEntity {
  const BudgetProgressModel({
    super.id,
    required super.category,
    required super.limitAmount,
    required super.spentAmount,
    required super.percentage,
    required super.isExceeded,
  });

  factory BudgetProgressModel.fromJson(Map<String, dynamic> json) {
    final limit = (json['budgetAmount'] as num?)?.toDouble() ?? 0.0;
    final spent = (json['spentAmount'] as num?)?.toDouble() ?? 0.0;
    final id = json['budgetId'] as int?;

    double percentage = 0.0;
    if (limit == 0) {
      percentage = spent > 0 ? 100.0 : 0.0;
    } else {
      final s = spent < 0 ? 0.0 : spent;
      final l = limit < 0 ? 0.0 : limit;
      if (l > 0) {
        percentage = (s / l) * 100;
      }
    }
    if (percentage.isNaN || percentage.isInfinite) {
      percentage = 0.0;
    }

    return BudgetProgressModel(
      id: id,
      category: json['category'] as String,
      limitAmount: limit,
      spentAmount: spent,
      percentage: percentage,
      isExceeded: json['exceedsBudget'] as bool? ?? false,
    );
  }
}
