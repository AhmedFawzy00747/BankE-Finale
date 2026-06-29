import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/global_search.dart';
import '../../../domain/entities/search_result_entity.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GlobalSearchUseCase searchUseCase;

  SearchBloc({required this.searchUseCase}) : super(SearchInitial()) {
    on<PerformSearchEvent>(_onSearch);
    on<ClearSearchEvent>(_onClear);
  }

  Future<void> _onSearch(PerformSearchEvent event, Emitter<SearchState> emit) async {
    final currentState = state;
    int pageToLoad = 1;
    List<SearchResultItemEntity> currentList = [];

    if (event.isLoadMore && currentState is SearchLoaded) {
      pageToLoad = currentState.currentPage + 1;
      currentList = currentState.results;
      emit(const SearchLoading(isLoadMore: true));
    } else {
      emit(const SearchLoading(isLoadMore: false));
    }

    try {
      final response = await searchUseCase.execute(event.query, page: pageToLoad);
      emit(SearchLoaded(
        results: event.isLoadMore
            ? [...currentList, ...response.items]
            : response.items,
        totalCount: response.totalCount,
        hasMore: response.hasMore,
        query: event.query,
        currentPage: pageToLoad,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClear(ClearSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
