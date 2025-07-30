part of '../base_data_imports.dart';

abstract class BaseRemoteDataSource {
  Future<List<T>> getData<T extends BaseEntity>(GetBaseEntityParams? param);

  Future<T> crudCall<T>(CrudBaseParmas param);
}

@LazySingleton(as: BaseRemoteDataSource)
class BaseRemoteDataSourceImpl implements BaseRemoteDataSource {
  final NetworkService dioService;

  BaseRemoteDataSourceImpl({required this.dioService});
  @override
  Future<List<T>> getData<T extends BaseEntity>(
      GetBaseEntityParams? param) async {
    return (await dioService.callApi<List<T>>(
      NetworkRequest(
          path: getBaseIdAndNameEntityApi<T>(param),
          queryParameters: param?.toJson(),
          method: RequestMethod.get),
      mapper: (json) => param?.mapper != null
          ? param!.mapper!<List<T>>(json)
          : List<T>.from(
              json.map((x) => baseIdAndNameEntityFromJson<T>(x)),
            ),
    ))
        .data;
  }

  @override
  Future<T> crudCall<T>(CrudBaseParmas param) async {
    return (await dioService.callApi<T>(
      NetworkRequest(
          path: param.api,
          method: param.httpRequestType.requestMethod,
          body: param.body,
          isFormData: param.isFromData,
          queryParameters: param.queryParameters,
          onSendProgress: param.onSendProgress),
      mapper: (json) => param.mapper(json),
    ))
        .data;
  }
}
