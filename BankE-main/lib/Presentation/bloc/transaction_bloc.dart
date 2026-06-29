import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_statement.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetStatementUseCase getStatementUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.getStatementUseCase,
  }) : super(TransactionInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<DownloadStatementEvent>(_onDownloadStatement);
  }

  Future<void> _onFetchTransactions(FetchTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await getTransactionsUseCase.execute(event.accountId);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDownloadStatement(DownloadStatementEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final pdfBytes = await getStatementUseCase.execute(event.startDate, event.endDate);
      emit(TransactionStatementDownloaded(pdfBytes));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
