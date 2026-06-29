import '../repositories/saving_goals_repository.dart';

class WithdrawSavingGoalFundsUseCase {
  final SavingGoalsRepository repository;

  WithdrawSavingGoalFundsUseCase(this.repository);

  Future<void> execute(int goalId, double amount) =>
      repository.withdrawFunds(goalId, amount);
}
