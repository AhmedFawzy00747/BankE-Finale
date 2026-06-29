import '../../core/api/other_services.dart';
import '../../core/api/api_client.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetService service;
  final ApiClient apiClient;

  BudgetRepositoryImpl({required this.service, required this.apiClient});

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final response = await service.getBudgets();
    apiClient.ensureSuccess(response);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => BudgetModel.fromJson(json)).toList();
  }

  @override
  Future<void> createBudget(
      String category, double amount, int month, int year, {double? spentAmount}) async {
    final response = await service.createBudget(category, amount, month, year, spentAmount: spentAmount);
    apiClient.ensureSuccess(response);
  }

  @override
  Future<List<BudgetProgressEntity>> getBudgetProgress(
      int month, int year) async {
    final response = await service.getBudgetProgress(month, year);
    apiClient.ensureSuccess(response);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => BudgetProgressModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateBudget(
      int id, String category, double amount, int month, int year, {double? spentAmount}) async {
    final response = await service.updateBudget(id, category, amount, month, year, spentAmount: spentAmount);
    apiClient.ensureSuccess(response);
  }

  @override
  Future<void> deleteBudget(int id) async {
    final response = await service.deleteBudget(id);
    apiClient.ensureSuccess(response);
  }
}
