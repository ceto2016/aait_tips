// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../config/res/constants_manager.dart';
import '../../../domain/base_domain_imports.dart';

part 'get_base_name_and_id_state.dart';

@Injectable()
class GetBaseEntityCubit<T extends BaseEntity> extends Cubit<GetBaseEntityState>
    with HydratedMixin {
  GetBaseEntityCubit()
    : super(GetBaseEntityState(dataState: Async<List<T>>.initial())) {
    getBaseEntityseCase = injector();
    hydrate();
  }

  late final GetBaseEntityUseCase getBaseEntityseCase;

  Future<void> fGetBaseNameAndId({int? id, bool idIsRequired = false}) async {
    log(T.runtimeType.toString());
    if (idIsRequired && id == null) {
      return;
    }
    emit(state.copyWith(data: Async<List<T>>.loading()));
    final result = await getBaseEntityseCase<T>(
      GetBaseEntityParams(id: id, paramsType: ParamsType.path),
    );
    result.when(
      (data) {
        emit(state.copyWith(data: Async<List<T>>.success(data)));
      },
      (failure) {
        emit(state.copyWith(data: Async<List<T>>.failure(failure)));
      },
    );
  }

  Future<void> fGetBaseNameAndIdWithQuery({
    required GetBaseEntityParams params,
  }) async {
    log(T.runtimeType.toString());
    emit(state.copyWith(data: Async<List<T>>.loading()));
    final result = await getBaseEntityseCase<T>(params);
    result.when(
      (data) {
        emit(state.copyWith(data: Async<List<T>>.success(data)));
      },
      (failure) {
        emit(state.copyWith(data: Async<List<T>>.failure(failure)));
      },
    );
  }

  @override
  GetBaseEntityState<BaseEntity>? fromJson(Map<String, dynamic> json) {
    final data = List<T>.from(
      json['data'].map((x) => baseIdAndNameEntityFromJson<T>(x)),
    );
    return GetBaseEntityState(dataState: Async<List<T>>.success(data));
  }

  @override
  Map<String, dynamic>? toJson(GetBaseEntityState<BaseEntity> state) {
    return {'data': state.dataState.data?.map((e) => e.toJson()).toList()};
  }
}

/**
 *   floatingActionButton: BlocProvider(
 *     create: (c) => GetBaseNameAndIdCubit<CategoryEntity>(),
 *     child: BlocBuilder<GetBaseNameAndIdCubit<CategoryEntity>,
 *         GetBaseNameAndIdState>(
 *       builder: (context, state) {
 *         return FloatingActionButton(
 *           onPressed: () {
 *             final cubit =
 *                 context.read<GetBaseNameAndIdCubit<CategoryEntity>>();
 *             cubit.fGetBaseNameAndIdWithQuery(
 *               params: GetBaseIdAndNameParams(
        //                 id: 39,
        //                 paramsType: ParamsType.query,
        //                 queryParameters: {
        //                   'scope': 'types',
        //                   'type': 'meals',
        //                   'all': 'false',
        //                 }),
        //           );
        //         },
        //         child: state.data.isLoading
        //             ? const CircularProgressIndicator(
        //                 color: AppColors.white,
        //               )
        //             : state.data.isSuccess
        //                 ? Builder(builder: (context) {
        //                     final list =
        //                         state.data.data as List<CategoryEntity>?;
        //                     if (list == null || list.isEmpty) {
        //                       return const Icon(Icons.add);
        //                     }
        //                     final firstItem = list.firstOrNull;
        //                     if (firstItem == null) {
        //                       return const Icon(Icons.add);
        //                     }
        //                     return Text(firstItem.name,
        //                         style: TextStyles.bold12
        //                             .copyWith(color: AppColors.white));
        //                   })
        //                 : const Icon(Icons.add),
        //       );
        //     },
        //   ),
        // ),
 */
