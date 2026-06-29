import '../repositories/budget_repository.dart';

class CreateBudgetUseCase {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  Future<void> execute(String category, double amount, int month, int year, {double? spentAmount}) =>
      repository.createBudget(category, amount, month, year, spentAmount: spentAmount);
}
