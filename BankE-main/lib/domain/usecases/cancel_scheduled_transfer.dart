import '../repositories/scheduled_transfer_repository.dart';

class CancelScheduledTransferUseCase {
  final ScheduledTransferRepository repository;

  CancelScheduledTransferUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.cancelScheduledTransfer(id);
  }
}
