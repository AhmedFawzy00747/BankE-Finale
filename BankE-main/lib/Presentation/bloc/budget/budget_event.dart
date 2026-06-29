abstract class BudgetEvent {
  const BudgetEvent();
}

class LoadBudgetsEvent extends BudgetEvent {
  const LoadBudgetsEvent();
}

class LoadBudgetProgressEvent extends BudgetEvent {
  final int month;
  final int year;

  const LoadBudgetProgressEvent({required this.month, required this.year});
}

class CreateBudgetEvent extends BudgetEvent {
  final String category;
  final double amount;
  final double? spentAmount;
  final int month;
  final int year;

  const CreateBudgetEvent({
    required this.category,
    required this.amount,
    this.spentAmount,
    required this.month,
    required this.year,
  });
}

class UpdateBudgetEvent extends BudgetEvent {
  final int id;
  final String category;
  final double amount;
  final double? spentAmount;
  final int month;
  final int year;

  const UpdateBudgetEvent({
    required this.id,
    required this.category,
    required this.amount,
    this.spentAmount,
    required this.month,
    required this.year,
  });
}

class DeleteBudgetEvent extends BudgetEvent {
  final int id;
  final int month;
  final int year;

  const DeleteBudgetEvent({
    required this.id,
    required this.month,
    required this.year,
  });
}
