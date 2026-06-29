import '../../../domain/entities/scheduled_transfer_entity.dart';

abstract class ScheduledTransferState {
  const ScheduledTransferState();
}

class ScheduledTransferInitial extends ScheduledTransferState {}

class ScheduledTransferLoading extends ScheduledTransferState {}

class ScheduledTransfersLoaded extends ScheduledTransferState {
  final List<ScheduledTransferEntity> transfers;

  const ScheduledTransfersLoaded(this.transfers);
}

class ScheduledTransferOperationSuccess extends ScheduledTransferState {
  final String message;

  const ScheduledTransferOperationSuccess(this.message);
}

class ScheduledTransferError extends ScheduledTransferState {
  final String message;

  const ScheduledTransferError(this.message);
}
