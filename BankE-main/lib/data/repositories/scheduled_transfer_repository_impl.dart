import '../../core/api/other_services.dart';
import '../../core/api/api_client.dart';
import '../../domain/entities/scheduled_transfer_entity.dart';
import '../../domain/repositories/scheduled_transfer_repository.dart';
import '../models/scheduled_transfer_model.dart';

class ScheduledTransferRepositoryImpl implements ScheduledTransferRepository {
  final ScheduledTransfersService service;
  final ApiClient apiClient;

  ScheduledTransferRepositoryImpl({
    required this.service,
    required this.apiClient,
  });

  @override
  Future<List<ScheduledTransferEntity>> getScheduledTransfers() async {
    final response = await service.getScheduledTransfers();
    apiClient.ensureSuccess(response);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ScheduledTransferModel.fromJson(json)).toList();
  }

  @override
  Future<void> createScheduledTransfer({
    required String receiverAccountNumber,
    required double amount,
    String? description,
    required DateTime scheduledDate,
    required String frequency,
  }) async {
    final response = await service.create(
      receiverAccountNumber,
      amount,
      description,
      scheduledDate,
      frequency,
    );
    apiClient.ensureSuccess(response);
  }

  @override
  Future<void> cancelScheduledTransfer(int id) async {
    final response = await service.cancel(id);
    apiClient.ensureSuccess(response);
  }
}
