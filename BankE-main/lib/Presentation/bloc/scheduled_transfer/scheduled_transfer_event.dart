abstract class ScheduledTransferEvent {
  const ScheduledTransferEvent();
}

class LoadScheduledTransfersEvent extends ScheduledTransferEvent {
  const LoadScheduledTransfersEvent();
}

class CreateScheduledTransferEvent extends ScheduledTransferEvent {
  final String receiverAccountNumber;
  final double amount;
  final String? description;
  final DateTime scheduledDate;
  final String frequency;

  const CreateScheduledTransferEvent({
    required this.receiverAccountNumber,
    required this.amount,
    this.description,
    required this.scheduledDate,
    required this.frequency,
  });
}

class CancelScheduledTransferEvent extends ScheduledTransferEvent {
  final int id;

  const CancelScheduledTransferEvent(this.id);
}
