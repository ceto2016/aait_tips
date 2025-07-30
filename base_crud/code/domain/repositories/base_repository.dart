part of '../base_domain_imports.dart';

abstract class BaseRepository {
  Future<Result<List<T>, Failure>> getBaseIdAndNameEntity<T extends BaseEntity>(
      GetBaseEntityParams? param);

  Future<Result<T, Failure>> crudCall<T>(
      CrudBaseParmas params);
}
