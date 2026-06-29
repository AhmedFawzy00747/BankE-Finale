import '../repositories/scheduled_transfer_repository.dart';

class CreateScheduledTransferUseCase {
  final ScheduledTransferRepository repository;

  CreateScheduledTransferUseCase(this.repository);

  Future<void> execute({
    required String receiverAccountNumber,
    required double amount,
    String? description,
    required DateTime scheduledDate,
    required String frequency,
  }) {
    return repository.createScheduledTransfer(
      receiverAccountNumber: receiverAccountNumber,
      amount: amount,
      description: description,
      scheduledDate: scheduledDate,
      frequency: frequency,
    );
  }
}
