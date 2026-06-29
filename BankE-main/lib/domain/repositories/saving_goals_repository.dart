import '../entities/saving_goal_entity.dart';

abstract class SavingGoalsRepository {
  Future<List<SavingGoalEntity>> getSavingGoals();
  Future<void> createSavingGoal(String name, double targetAmount, DateTime targetDate);
  Future<void> addFunds(int goalId, double amount);
  Future<void> withdrawFunds(int goalId, double amount);
  Future<void> updateSavingGoal(int goalId, String name, double targetAmount, DateTime targetDate);
  Future<void> deleteSavingGoal(int goalId);
}
