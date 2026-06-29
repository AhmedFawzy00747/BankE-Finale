import '../../../domain/entities/budget_entity.dart';

abstract class BudgetState {
  const BudgetState();
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetsLoaded extends BudgetState {
  final List<BudgetEntity> budgets;

  const BudgetsLoaded(this.budgets);
}

class BudgetProgressLoaded extends BudgetState {
  final List<BudgetProgressEntity> progressList;

  const BudgetProgressLoaded(this.progressList);
}

class BudgetOperationSuccess extends BudgetState {
  final String message;

  const BudgetOperationSuccess(this.message);
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);
}
