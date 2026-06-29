import '../../../domain/entities/saving_goal_entity.dart';

abstract class SavingGoalState {
  const SavingGoalState();
}

class SavingGoalInitial extends SavingGoalState {}

class SavingGoalLoading extends SavingGoalState {}

class SavingGoalsLoaded extends SavingGoalState {
  final List<SavingGoalEntity> goals;

  const SavingGoalsLoaded(this.goals);
}

class SavingGoalOperationSuccess extends SavingGoalState {
  final String message;

  const SavingGoalOperationSuccess(this.message);
}

class SavingGoalError extends SavingGoalState {
  final String message;

  const SavingGoalError(this.message);
}
