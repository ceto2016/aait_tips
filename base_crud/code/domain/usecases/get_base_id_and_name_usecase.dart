part of '../base_domain_imports.dart';

@LazySingleton()
class GetBaseEntityUseCase {
  final BaseRepository repository;

  GetBaseEntityUseCase({required this.repository});

  Future<Result<List<T>, Failure>> call<T extends BaseEntity>(
      GetBaseEntityParams? param) async {
    return await repository.getBaseIdAndNameEntity<T>(param);
  }
}

enum ParamsType {
  path,
  query,
}

class GetBaseEntityParams<T extends BaseIdAndNameEntity> {
  final int? id;
  final ParamsType paramsType;
  final Map<String, dynamic> queryParameters;
  final T Function<T>(Map<String, dynamic> json)? mapper;
  GetBaseEntityParams(
      {this.id,
      this.mapper,
      this.paramsType = ParamsType.path,
      this.queryParameters = const {}});
  //toJson
  Map<String, dynamic> toJson() {
    if (paramsType == ParamsType.path) return {};

    return queryParameters;
  }
}
