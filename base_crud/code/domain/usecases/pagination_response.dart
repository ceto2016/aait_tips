import '../base_domain_imports.dart';

class BaseModel<T> {
  final String key;
  final String msg;
  final T? data;
  BaseModel({required this.key, required this.msg, this.data});

  factory BaseModel.fromMap(Map<String, dynamic> map,
      {T Function(dynamic)? mapper}) {
    return BaseModel<T>(
      key: map['key'] as String,
      msg: map['msg'] as String,
      data: map['data'] != null && mapper != null ? mapper(map['data']) : null,
    );
  }
}

class PaginationResponse<T> extends CrudResponse {
  final Pagination? pagination;

  final List<T>? data;
  PaginationResponse({required this.pagination, this.data});

  factory PaginationResponse.fromJson(Map<String, dynamic> map,
      {List<T> Function(dynamic)? mapper, String? dataKey}) {
    return PaginationResponse<T>(
      pagination: map["pagination"] != null
          ? Pagination.fromJson(map["pagination"])
          : null,
      data: map[dataKey ?? 'data'] != null && mapper != null
          ? mapper(map[dataKey ?? 'data'])
          : null,
    );
  }

  PaginationResponse<T> copyWith({
    Pagination? pagination,
    List<T>? data,
  }) {
    return PaginationResponse<T>(
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }
}

class Pagination {
  final int totalItems;
  final int countItems;
  final int perPage;
  final int totalPages;
  final int currentPage;
  final String nextPageUrl;
  final String pervPageUrl;

  Pagination({
    required this.totalItems,
    required this.countItems,
    required this.perPage,
    required this.totalPages,
    required this.currentPage,
    required this.nextPageUrl,
    required this.pervPageUrl,
  });

  Pagination copyWith({
    int? totalItems,
    int? countItems,
    int? perPage,
    int? totalPages,
    int? currentPage,
    String? nextPageUrl,
    String? pervPageUrl,
  }) =>
      Pagination(
        totalItems: totalItems ?? this.totalItems,
        countItems: countItems ?? this.countItems,
        perPage: perPage ?? this.perPage,
        totalPages: totalPages ?? this.totalPages,
        currentPage: currentPage ?? this.currentPage,
        nextPageUrl: nextPageUrl ?? this.nextPageUrl,
        pervPageUrl: pervPageUrl ?? this.pervPageUrl,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalItems: json["total_items"],
        countItems: json["count_items"],
        perPage: json["per_page"],
        totalPages: json["total_pages"],
        currentPage: json["current_page"],
        nextPageUrl: json["next_page_url"],
        pervPageUrl: json["perv_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "total_items": totalItems,
        "count_items": countItems,
        "per_page": perPage,
        "total_pages": totalPages,
        "current_page": currentPage,
        "next_page_url": nextPageUrl,
        "perv_page_url": pervPageUrl,
      };
}

class BaseKeyMessageModel<T> {
  final String key;
  final String msg;
  BaseKeyMessageModel({required this.key, required this.msg});

  factory BaseKeyMessageModel.fromMap(Map<String, dynamic> map,
      {T Function(dynamic)? mapper}) {
    return BaseKeyMessageModel<T>(
      key: map['key'] as String,
      msg: map['msg'] as String,
    );
  }
}
