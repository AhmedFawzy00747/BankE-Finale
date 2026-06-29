import '../repositories/saving_goals_repository.dart';

class CreateSavingGoalUseCase {
  final SavingGoalsRepository repository;

  CreateSavingGoalUseCase(this.repository);

  Future<void> execute(String name, double targetAmount, DateTime targetDate) =>
      repository.createSavingGoal(name, targetAmount, targetDate);
}
