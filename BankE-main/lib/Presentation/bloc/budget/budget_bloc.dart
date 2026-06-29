import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_budgets.dart';
import '../../../domain/usecases/create_budget.dart';
import '../../../domain/usecases/get_budget_progress.dart';
import '../../../domain/usecases/update_budget.dart';
import '../../../domain/usecases/delete_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetsUseCase getBudgetsUseCase;
  final CreateBudgetUseCase createBudgetUseCase;
  final GetBudgetProgressUseCase getBudgetProgressUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;

  BudgetBloc({
    required this.getBudgetsUseCase,
    required this.createBudgetUseCase,
    required this.getBudgetProgressUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
  }) : super(BudgetInitial()) {
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<LoadBudgetProgressEvent>(_onLoadProgress);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(LoadBudgetsEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final budgets = await getBudgetsUseCase.execute();
      emit(BudgetsLoaded(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onLoadProgress(LoadBudgetProgressEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final progress = await getBudgetProgressUseCase.execute(event.month, event.year);
      emit(BudgetProgressLoaded(progress));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onCreateBudget(CreateBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await createBudgetUseCase.execute(
        event.category,
        event.amount,
        event.month,
        event.year,
        spentAmount: event.spentAmount,
      );
      emit(const BudgetOperationSuccess('Budget updated successfully'));
      add(LoadBudgetProgressEvent(month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateBudget(UpdateBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await updateBudgetUseCase.execute(
        event.id,
        event.category,
        event.amount,
        event.month,
        event.year,
        spentAmount: event.spentAmount,
      );
      emit(const BudgetOperationSuccess('Budget updated successfully'));
      add(LoadBudgetProgressEvent(month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudget(DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await deleteBudgetUseCase.execute(event.id);
      emit(const BudgetOperationSuccess('Budget deleted successfully'));
      add(LoadBudgetProgressEvent(month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
