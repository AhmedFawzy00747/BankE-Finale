import '../repositories/saving_goals_repository.dart';

class DeleteSavingGoalUseCase {
  final SavingGoalsRepository repository;

  DeleteSavingGoalUseCase(this.repository);

  Future<void> execute(int goalId) =>
      repository.deleteSavingGoal(goalId);
}
