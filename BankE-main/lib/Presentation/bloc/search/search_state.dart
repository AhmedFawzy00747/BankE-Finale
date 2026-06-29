import '../../../domain/entities/search_result_entity.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final bool isLoadMore;

  const SearchLoading({this.isLoadMore = false});
}

class SearchLoaded extends SearchState {
  final List<SearchResultItemEntity> results;
  final int totalCount;
  final bool hasMore;
  final String query;
  final int currentPage;

  const SearchLoaded({
    required this.results,
    required this.totalCount,
    required this.hasMore,
    required this.query,
    required this.currentPage,
  });
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);
}
