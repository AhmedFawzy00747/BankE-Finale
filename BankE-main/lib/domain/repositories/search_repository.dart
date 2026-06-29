import '../entities/search_result_entity.dart';

abstract class SearchRepository {
  Future<SearchResponseEntity> search(String query, {int page = 1, int pageSize = 10});
}
