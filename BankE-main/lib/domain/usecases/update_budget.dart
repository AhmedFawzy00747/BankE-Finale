import '../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<void> execute(int id, String category, double amount, int month, int year, {double? spentAmount}) =>
      repository.updateBudget(id, category, amount, month, year, spentAmount: spentAmount);
}
