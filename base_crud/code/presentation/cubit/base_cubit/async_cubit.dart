import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:whatsgood/src/config/res/constants_manager.dart';
import 'package:whatsgood/src/core/helpers/toast.dart';

import '../../../../../error/failure.dart';
import '../../../../base_state.dart';
import '../../../domain/base_domain_imports.dart';

part 'async_state.dart';

abstract class AsyncCubit<T> extends Cubit<AsyncState<T>> {
  AsyncCubit(T initialData) : super(AsyncState.initial(data: initialData)) {
    baseCrudUseCase = injector();
  }
  late final BaseCrudUseCase baseCrudUseCase;
  void setLoading() {
    emit(state.loading());
  }

  void setLoadingMore() {
    emit(state.loadingMore());
  }

  void setSuccess({required T data}) {
    emit(state.success(data: data));
  }

  void setError({String? errorMessage, bool showToast = false}) {
    if (showToast && errorMessage != null) {
      showErrorToast(errorMessage);
    }
    emit(state.error(errorMessage: errorMessage));
  }

  void reset() {
    emit(AsyncState.initial(data: state.data));
  }

  void updateData(T data) {
    emit(state.copyWith(data: data));
  }

  void updateErrorMessage(String? errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage));
  }

  bool get isLoading => state.isLoading;

  Future<void> executeAsync({
    required Future<Result<T, Failure>> Function() operation,
    Function(T)? successEmitter,
  }) async {
    setLoading();
    final result = await operation();
    result.when(
      (success) {
        setSuccess(data: success);
        if (successEmitter != null) {
          successEmitter(success);
        }
      },
      (failure) {
        showToast(failure.message);
        setError(errorMessage: failure.message);
      },
    );
  }

  @override
  void emit(AsyncState<T> state) {
    if (isClosed) return;
    super.emit(state);
  }
}
