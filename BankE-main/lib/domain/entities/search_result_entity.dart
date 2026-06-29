class SearchResultItemEntity {
  final String type;
  final int id;
  final String title;
  final String subtitle;
  final String? extraInfo;
  final DateTime date;

  const SearchResultItemEntity({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.extraInfo,
    required this.date,
  });
}

class SearchResponseEntity {
  final List<SearchResultItemEntity> items;
  final int totalCount;
  final bool hasMore;

  const SearchResponseEntity({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });
}
