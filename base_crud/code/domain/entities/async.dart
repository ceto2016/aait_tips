part of '../base_domain_imports.dart';

class Async<T> extends Equatable {
  final T? data;
  final Failure? failure;
  final bool _successWithoutData;
  final bool? _loading;

  const Async._(
    this.data,
    this._successWithoutData,
    this._loading,
    this.failure,
  );

  String? get errorMessage => failure?.message;

  bool get isLoading => _loading ?? false;

  bool get isSuccess =>
      (_successWithoutData || data != null) && (failure == null);

  bool get isFailure => failure != null;

  bool get isInitial =>
      (data == null) &&
      (failure == null) &&
      (_successWithoutData == false) &&
      (_loading == null);

  const Async.loading() : this._(null, false, true, null);

  const Async.loadingMore(T data) : this._(data, false, false, null);

  const Async.success(T data) : this._(data, false, false, null);

  const Async.successWithoutData() : this._(null, true, false, null);

  const Async.failure(Failure failure) : this._(null, false, false, failure);

  const Async.initial() : this._(null, false, null, null);

  @override
  String toString() {
    return "Async : [data]: $data , [Failure]: ${failure.runtimeType} , [isFailure] : $isFailure , [isLoading] : $isLoading , [isSuccess] : $isSuccess ,[isInitial] $isInitial";
  }

  @override
  List<Object?> get props => [
        data,
        _successWithoutData,
        _loading,
        isFailure,
        isLoading,
        isSuccess,
        isInitial,
        failure,
      ];
}
