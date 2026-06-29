import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_saving_goals.dart';
import '../../../domain/usecases/create_saving_goal.dart';
import '../../../domain/usecases/add_saving_goal_funds.dart';
import '../../../domain/usecases/withdraw_saving_goal_funds.dart';
import '../../../domain/usecases/update_saving_goal.dart';
import '../../../domain/usecases/delete_saving_goal.dart';
import 'saving_goal_event.dart';
import 'saving_goal_state.dart';

class SavingGoalBloc extends Bloc<SavingGoalEvent, SavingGoalState> {
  final GetSavingGoalsUseCase getGoalsUseCase;
  final CreateSavingGoalUseCase createGoalUseCase;
  final AddSavingGoalFundsUseCase addFundsUseCase;
  final WithdrawSavingGoalFundsUseCase withdrawFundsUseCase;
  final UpdateSavingGoalUseCase updateGoalUseCase;
  final DeleteSavingGoalUseCase deleteGoalUseCase;

  SavingGoalBloc({
    required this.getGoalsUseCase,
    required this.createGoalUseCase,
    required this.addFundsUseCase,
    required this.withdrawFundsUseCase,
    required this.updateGoalUseCase,
    required this.deleteGoalUseCase,
  }) : super(SavingGoalInitial()) {
    on<LoadSavingGoalsEvent>(_onLoadGoals);
    on<CreateSavingGoalEvent>(_onCreateGoal);
    on<AddSavingGoalFundsEvent>(_onAddFunds);
    on<WithdrawSavingGoalFundsEvent>(_onWithdrawFunds);
    on<UpdateSavingGoalEvent>(_onUpdateGoal);
    on<DeleteSavingGoalEvent>(_onDeleteGoal);
  }

  Future<void> _onLoadGoals(LoadSavingGoalsEvent event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      final goals = await getGoalsUseCase.execute();
      emit(SavingGoalsLoaded(goals));
    } catch (e) {
      emit(SavingGoalError(e.toString()));
    }
  }

  Future<void> _onCreateGoal(CreateSavingGoalEvent event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      await createGoalUseCase.execute(event.name, event.targetAmount, event.targetDate);
      emit(const SavingGoalOperationSuccess('Saving goal created successfully'));
      add(const LoadSavingGoalsEvent());
    } catch (e) {
      emit(SavingGoalError(e.toString()));
    }
  }

  Future<void> _onAddFunds(AddSavingGoalFundsEvent event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      await addFundsUseCase.execute(event.goalId, event.amount);
      emit(const SavingGoalOperationSuccess('Funds added successfully'));
      add(const LoadSavingGoalsEvent());
    } catch (e) {
      emit(SavingGoalError(e.toString()));
    }
  }

  Future<void> _onWithdrawFunds(WithdrawSavingGoalFundsEvent event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      await withdrawFundsUseCase.execute(event.goalId, event.amount);
      emit(const SavingGoalOperationSuccess('Funds withdrawn successfully'));
      add(const LoadSavingGoalsEvent());
    } catch (e) {
      emit(SavingGoalError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(UpdateSavingGoalEvent event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      await updateGoalUseCase.execute(
        goalId: event.goalId,
        name: event.name,
        targetAmount: event.targetAmount,
        targetDate: event.targetDate,
      );
      emit(const SavingGoalOperationSuccess('Saving goal updated successfully'));
      add(const LoadSavingGoalsEvent());
    } catch (e) {
      emit(SavingGoalError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(DeleteSavingGoalEvent event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      await deleteGoalUseCase.execute(event.goalId);
      emit(const SavingGoalOperationSuccess('Saving goal deleted successfully'));
      add(const LoadSavingGoalsEvent());
    } catch (e) {
      emit(SavingGoalError(e.toString()));
    }
  }
}
