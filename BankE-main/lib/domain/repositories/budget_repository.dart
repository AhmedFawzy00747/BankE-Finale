import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getBudgets();
  Future<void> createBudget(String category, double amount, int month, int year, {double? spentAmount});
  Future<List<BudgetProgressEntity>> getBudgetProgress(int month, int year);
  Future<void> updateBudget(int id, String category, double amount, int month, int year, {double? spentAmount});
  Future<void> deleteBudget(int id);
}
