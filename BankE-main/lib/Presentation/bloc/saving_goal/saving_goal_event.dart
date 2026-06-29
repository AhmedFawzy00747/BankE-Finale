abstract class SavingGoalEvent {
  const SavingGoalEvent();
}

class LoadSavingGoalsEvent extends SavingGoalEvent {
  const LoadSavingGoalsEvent();
}

class CreateSavingGoalEvent extends SavingGoalEvent {
  final String name;
  final double targetAmount;
  final DateTime targetDate;

  const CreateSavingGoalEvent({
    required this.name,
    required this.targetAmount,
    required this.targetDate,
  });
}

class AddSavingGoalFundsEvent extends SavingGoalEvent {
  final int goalId;
  final double amount;

  const AddSavingGoalFundsEvent({
    required this.goalId,
    required this.amount,
  });
}

class WithdrawSavingGoalFundsEvent extends SavingGoalEvent {
  final int goalId;
  final double amount;

  const WithdrawSavingGoalFundsEvent({
    required this.goalId,
    required this.amount,
  });
}

class UpdateSavingGoalEvent extends SavingGoalEvent {
  final int goalId;
  final String name;
  final double targetAmount;
  final DateTime targetDate;

  const UpdateSavingGoalEvent({
    required this.goalId,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
  });
}

class DeleteSavingGoalEvent extends SavingGoalEvent {
  final int goalId;

  const DeleteSavingGoalEvent(this.goalId);
}
