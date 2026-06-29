import '../entities/scheduled_transfer_entity.dart';

abstract class ScheduledTransferRepository {
  Future<List<ScheduledTransferEntity>> getScheduledTransfers();
  Future<void> createScheduledTransfer({
    required String receiverAccountNumber,
    required double amount,
    String? description,
    required DateTime scheduledDate,
    required String frequency,
  });
  Future<void> cancelScheduledTransfer(int id);
}
