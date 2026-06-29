import 'package:equatable/equatable.dart';
import 'dart:typed_data';
import '../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionStatementDownloaded extends TransactionState {
  final Uint8List pdfBytes;

  const TransactionStatementDownloaded(this.pdfBytes);

  @override
  List<Object?> get props => [pdfBytes];
}
