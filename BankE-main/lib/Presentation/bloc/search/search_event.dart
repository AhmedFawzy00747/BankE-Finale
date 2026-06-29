abstract class SearchEvent {
  const SearchEvent();
}

class PerformSearchEvent extends SearchEvent {
  final String query;
  final bool isLoadMore;

  const PerformSearchEvent(this.query, {this.isLoadMore = false});
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}
