import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:whatsgood/src/core/shared/cubits/user_cubit/user_cubit.dart';
import 'package:whatsgood/src/core/shared/lookups_cubit/domain/entities/faqs.dart';
import 'package:whatsgood/src/features/user/home/domain/entities/category_enitity.dart';

import '../../../error/failure.dart';
import '../../../network/network_request.dart';
import 'entities/country_entity.dart';

part 'entities/async.dart';
part 'entities/base_name_and_id_entity.dart';
part 'repositories/base_repository.dart';
part 'usecases/base_crud.dart';
part 'usecases/get_base_id_and_name_usecase.dart';
