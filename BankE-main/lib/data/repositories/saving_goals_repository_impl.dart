import '../../core/api/other_services.dart';
import '../../core/api/api_client.dart';
import '../../domain/entities/saving_goal_entity.dart';
import '../../domain/repositories/saving_goals_repository.dart';
import '../models/saving_goal_model.dart';

class SavingGoalsRepositoryImpl implements SavingGoalsRepository {
  final SavingGoalsService service;
  final ApiClient apiClient;

  SavingGoalsRepositoryImpl({required this.service, required this.apiClient});

  @override
  Future<List<SavingGoalEntity>> getSavingGoals() async {
    final response = await service.getSavingGoals();
    apiClient.ensureSuccess(response);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => SavingGoalModel.fromJson(json)).toList();
  }

  @override
  Future<void> createSavingGoal(
      String name, double targetAmount, DateTime targetDate) async {
    final response = await service.createGoal(name, targetAmount, targetDate);
    apiClient.ensureSuccess(response);
  }

  @override
  Future<void> addFunds(int goalId, double amount) async {
    final response = await service.addFunds(goalId, amount);
    apiClient.ensureSuccess(response);
  }

  @override
  Future<void> withdrawFunds(int goalId, double amount) async {
    final response = await service.withdrawFunds(goalId, amount);
    apiClient.ensureSuccess(response);
  }

  @override
  Future<void> updateSavingGoal(int goalId, String name, double targetAmount, DateTime targetDate) async {
    final response = await service.updateGoal(goalId, name, targetAmount, targetDate);
    apiClient.ensureSuccess(response);
  }

  @override
  Future<void> deleteSavingGoal(int goalId) async {
    final response = await service.deleteGoal(goalId);
    apiClient.ensureSuccess(response);
  }
}
