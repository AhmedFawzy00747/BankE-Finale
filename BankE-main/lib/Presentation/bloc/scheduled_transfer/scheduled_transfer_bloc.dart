import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_scheduled_transfers.dart';
import '../../../domain/usecases/create_scheduled_transfer.dart';
import '../../../domain/usecases/cancel_scheduled_transfer.dart';
import 'scheduled_transfer_event.dart';
import 'scheduled_transfer_state.dart';

class ScheduledTransferBloc
    extends Bloc<ScheduledTransferEvent, ScheduledTransferState> {
  final GetScheduledTransfersUseCase getTransfersUseCase;
  final CreateScheduledTransferUseCase createTransferUseCase;
  final CancelScheduledTransferUseCase cancelTransferUseCase;

  ScheduledTransferBloc({
    required this.getTransfersUseCase,
    required this.createTransferUseCase,
    required this.cancelTransferUseCase,
  }) : super(ScheduledTransferInitial()) {
    on<LoadScheduledTransfersEvent>(_onLoadTransfers);
    on<CreateScheduledTransferEvent>(_onCreateTransfer);
    on<CancelScheduledTransferEvent>(_onCancelTransfer);
  }

  Future<void> _onLoadTransfers(LoadScheduledTransfersEvent event,
      Emitter<ScheduledTransferState> emit) async {
    emit(ScheduledTransferLoading());
    try {
      final transfers = await getTransfersUseCase.execute();

      print("TRANSFERS:");
      print(transfers);
      print(transfers.runtimeType);

      emit(ScheduledTransfersLoaded(transfers));
    } catch (e, s) {
      print(e);
      print(s);
      emit(ScheduledTransferError(e.toString()));
    }
  }

  Future<void> _onCreateTransfer(CreateScheduledTransferEvent event,
      Emitter<ScheduledTransferState> emit) async {
    emit(ScheduledTransferLoading());
    try {
      await createTransferUseCase.execute(
        receiverAccountNumber: event.receiverAccountNumber,
        amount: event.amount,
        description: event.description,
        scheduledDate: event.scheduledDate,
        frequency: event.frequency,
      );
      emit(const ScheduledTransferOperationSuccess(
          'Transfer scheduled successfully'));
      add(const LoadScheduledTransfersEvent());
    } catch (e) {
      emit(ScheduledTransferError(e.toString()));
    }
  }

  Future<void> _onCancelTransfer(CancelScheduledTransferEvent event,
      Emitter<ScheduledTransferState> emit) async {
    emit(ScheduledTransferLoading());
    try {
      await cancelTransferUseCase.execute(event.id);
      emit(const ScheduledTransferOperationSuccess(
          'Scheduled transfer cancelled'));
      add(const LoadScheduledTransfersEvent());
    } catch (e) {
      emit(ScheduledTransferError(e.toString()));
    }
  }
}
