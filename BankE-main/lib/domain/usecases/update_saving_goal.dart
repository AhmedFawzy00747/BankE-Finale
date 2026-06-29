import '../repositories/saving_goals_repository.dart';

class UpdateSavingGoalUseCase {
  final SavingGoalsRepository repository;

  UpdateSavingGoalUseCase(this.repository);

  Future<void> execute({
    required int goalId,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) =>
      repository.updateSavingGoal(goalId, name, targetAmount, targetDate);
}
