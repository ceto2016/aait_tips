// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'get_base_name_and_id_cubit.dart';

class GetBaseEntityState<T extends BaseEntity> extends Equatable {
  const GetBaseEntityState({
    required this.dataState,
  });
  final Async<List<T>> dataState;

  GetBaseEntityState copyWith({
    Async<List<T>>? data,
  }) {
    return GetBaseEntityState(
      dataState: data ?? this.dataState,
    );
  }

  @override
  List<Object> get props => [dataState];
}
