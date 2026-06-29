import '../repositories/saving_goals_repository.dart';

class AddSavingGoalFundsUseCase {
  final SavingGoalsRepository repository;

  AddSavingGoalFundsUseCase(this.repository);

  Future<void> execute(int goalId, double amount) =>
      repository.addFunds(goalId, amount);
}
