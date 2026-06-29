import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactions extends TransactionEvent {
  final String accountId;

  const FetchTransactions(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class DownloadStatementEvent extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const DownloadStatementEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
