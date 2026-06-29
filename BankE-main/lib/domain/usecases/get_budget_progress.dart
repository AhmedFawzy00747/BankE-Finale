import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgetProgressUseCase {
  final BudgetRepository repository;

  GetBudgetProgressUseCase(this.repository);

  Future<List<BudgetProgressEntity>> execute(int month, int year) =>
      repository.getBudgetProgress(month, year);
}
