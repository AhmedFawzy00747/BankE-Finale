import '../entities/search_result_entity.dart';
import '../repositories/search_repository.dart';

class GlobalSearchUseCase {
  final SearchRepository repository;

  GlobalSearchUseCase(this.repository);

  Future<SearchResponseEntity> execute(String query, {int page = 1, int pageSize = 10}) {
    return repository.search(query, page: page, pageSize: pageSize);
  }
}
