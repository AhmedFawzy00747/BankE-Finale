import '../../domain/entities/search_result_entity.dart';

class SearchResultItemModel extends SearchResultItemEntity {
  const SearchResultItemModel({
    required super.type,
    required super.id,
    required super.title,
    required super.subtitle,
    super.extraInfo,
    required super.date,
  });

  factory SearchResultItemModel.fromJson(Map<String, dynamic> json) {
    return SearchResultItemModel(
      type: json['type'] as String,
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      extraInfo: json['extraInfo'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class SearchResponseModel extends SearchResponseEntity {
  const SearchResponseModel({
    required super.items,
    required super.totalCount,
    required super.hasMore,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsList = json['items'] ?? [];
    return SearchResponseModel(
      items: itemsList.map((i) => SearchResultItemModel.fromJson(i)).toList(),
      totalCount: json['totalCount'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}
