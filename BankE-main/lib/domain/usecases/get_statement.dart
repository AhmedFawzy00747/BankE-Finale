import 'dart:typed_data';
import '../repositories/account_repository.dart';

class GetStatementUseCase {
  final AccountRepository repository;

  GetStatementUseCase(this.repository);

  Future<Uint8List> execute(DateTime startDate, DateTime endDate) {
    return repository.downloadStatement(startDate, endDate);
  }
}
