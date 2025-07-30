part of 'async_cubit.dart';

class AsyncState<T> extends Equatable {
  final BaseStatus status;
  final T data;
  final String? errorMessage;

  const AsyncState({
    this.status = BaseStatus.initial,
    required this.data,
    this.errorMessage,
  });

  factory AsyncState.initial({
    required T data,
    String? errorMessage,
  }) {
    return AsyncState<T>(
      status: BaseStatus.initial,
      data: data,
      errorMessage: errorMessage,
    );
  }

  AsyncState<T> loading({
    T? data,
    String? errorMessage,
  }) {
    return AsyncState<T>(
      status: BaseStatus.loading,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  AsyncState<T> loadingMore({T? data, String? errorMessage}) {
    return AsyncState<T>(
      status: BaseStatus.loadingMore,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AsyncState<T> success({
    required T data,
    String? errorMessage,
  }) {
    return AsyncState<T>(
      status: BaseStatus.success,
      data: data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AsyncState<T> error({
    String? errorMessage,
    T? data,
  }) {
    return AsyncState<T>(
      status: BaseStatus.error,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];

  bool get isInitial => status.isInitial;

  bool get isLoading => status.isLoading;

  bool get isLoadingMore => status.isLoadingMore;

  bool get isSuccess => status.isSuccess;

  bool get isError => status.isError;

  AsyncState<T> copyWith({
    BaseStatus? status,
    T? data,
    String? errorMessage,
  }) {
    return AsyncState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
