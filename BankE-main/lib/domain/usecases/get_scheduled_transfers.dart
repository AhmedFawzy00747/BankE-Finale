import '../entities/scheduled_transfer_entity.dart';
import '../repositories/scheduled_transfer_repository.dart';

class GetScheduledTransfersUseCase {
  final ScheduledTransferRepository repository;

  GetScheduledTransfersUseCase(this.repository);

  Future<List<ScheduledTransferEntity>> execute() {
    return repository.getScheduledTransfers();
  }
}
