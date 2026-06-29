import '../../core/api/other_services.dart';
import '../../core/api/api_client.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../models/search_result_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchService service;
  final ApiClient apiClient;

  SearchRepositoryImpl({required this.service, required this.apiClient});

  @override
  Future<SearchResponseEntity> search(String query,
      {int page = 1, int pageSize = 10}) async {
    final response =
        await service.search(query, page: page, pageSize: pageSize);
    apiClient.ensureSuccess(response);
    return SearchResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
