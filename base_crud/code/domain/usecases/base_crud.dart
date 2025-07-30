// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../base_domain_imports.dart';

@LazySingleton()
class BaseCrudUseCase {
  final BaseRepository repository;
  BaseCrudUseCase({required this.repository});
  Future<Result<T, Failure>> call<T>(
      CrudBaseParmas param) async {
    return await repository.crudCall<T>(param);
  }
}

class CrudResponse {}

enum HttpRequestType {
  get(requestMethod: RequestMethod.get),
  post(requestMethod: RequestMethod.post),
  put(requestMethod: RequestMethod.put),
  patch(requestMethod: RequestMethod.patch),
  delete(requestMethod: RequestMethod.delete);

  final RequestMethod requestMethod;
  const HttpRequestType({required this.requestMethod});
}

class CrudBaseParmas<T> {
  final String api;
  final HttpRequestType httpRequestType;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? queryParameters;
  final T Function(dynamic) mapper;
  final bool isFromData;
  final void Function(int, int)? onSendProgress;
  CrudBaseParmas(
      {required this.api,
      required this.httpRequestType,
      this.body,
      this.queryParameters,
      this.onSendProgress,
      this.isFromData = false,
      required this.mapper});

  CrudBaseParmas<T> copyWith({
    String? api,
    HttpRequestType? httpRequestType,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? mapper,
    bool? isFromData,
  }) {
    return CrudBaseParmas<T>(
      api: api ?? this.api,
      httpRequestType: httpRequestType ?? this.httpRequestType,
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      mapper: mapper ?? this.mapper,
      isFromData: isFromData ?? this.isFromData,
    );
  }
}
