import '../entities/saving_goal_entity.dart';
import '../repositories/saving_goals_repository.dart';

class GetSavingGoalsUseCase {
  final SavingGoalsRepository repository;

  GetSavingGoalsUseCase(this.repository);

  Future<List<SavingGoalEntity>> execute() => repository.getSavingGoals();
}
