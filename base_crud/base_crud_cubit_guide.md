# دليل شامل لنظام Base CRUD Cubit

## 1. شرح AsyncCubit (النمط الجديد المبسط)

`AsyncCubit` هو نمط مطور ومبسط للتعامل مع العمليات غير المتزامنة في Flutter. بيوفر طريقة أسهل وأكثر مرونة من الطريقة التقليدية.

### مكونات AsyncCubit

#### AsyncState
```dart
class AsyncState<T> extends Equatable {
  final BaseStatus status;
  final T data;
  final String? errorMessage;
  
  bool get isInitial => status.isInitial;
  bool get isLoading => status.isLoading;
  bool get isLoadingMore => status.isLoadingMore;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;
}
```

**الحالات المدعومة:**
- `BaseStatus.initial` - الحالة الأولية
- `BaseStatus.loading` - أثناء التحميل الأول
- `BaseStatus.loadingMore` - أثناء التحميل الإضافي (pagination)
- `BaseStatus.success` - نجح العملية
- `BaseStatus.error` - حدث خطأ

#### AsyncCubit Abstract Class
```dart
abstract class AsyncCubit<T> extends Cubit<AsyncState<T>> {
  AsyncCubit(T initialData) : super(AsyncState.initial(data: initialData));
  late final BaseCrudUseCase baseCrudUseCase;
  
  // وظائف مساعدة
  void setLoading();
  void setLoadingMore();
  void setSuccess({required T data});
  void setError({String? errorMessage, bool showToast = false});
  void reset();
  void updateData(T data);
  
  // الوظيفة الأساسية لتنفيذ العمليات
  Future<void> executeAsync({
    required Future<Result<T, Failure>> Function() operation,
    Function(T)? successEmitter,
  });
}
```

### مثال عملي على AsyncCubit

#### 1. إنشاء UserCubit
```dart
class UserCubit extends AsyncCubit<List<User>> {
  UserCubit() : super([]); // البيانات الأولية قائمة فارغة
  
  // جلب قائمة المستخدمين
  Future<void> getUsers() async {
    await executeAsync(
      operation: () => baseCrudUseCase<List<User>>(
        CrudBaseParmas(
          api: "users",
          httpRequestType: HttpRequestType.get,
          mapper: (json) => (json as List)
              .map((user) => User.fromJson(user))
              .toList(),
        ),
      ),
      successEmitter: (users) {
        // أي إجراء إضافي بعد النجاح
        print("تم جلب ${users.length} مستخدم");
      },
    );
  }
  
}
```

## ملاحظة
 انت هنا ينفع تضيف اكتر من ميثود بس اتاكد انه كلهم هيبقوا نفس ال ruturn type ,
او انك متستخدمش executeAsync .. وتنادي بس baseCrudUseCase ومتعملش emit ,
لو عايز بقي تعمل كيوبت اكثر تعقيدا ينفع تستخدم بس  baseCrudUseCase 
جواه وتعمل cubit وال state علي مزاجك

```dart
  Future<void> _newPhone({required String code}) async {
    final result = await baseCrudUseCase<String>(
      CrudBaseParams(
        api: verifyNewPhoneApi,
        httpRequestType: HttpRequestType.post,
        body: {'phone': phone, 'code': code, ...authBaseMap},
        mapper: (value) =>
            LocaleKeys.forget_password_reset_password_successfully.tr(),
      ),
    );
    result.when(
      (response) {
        UserCubit.instance.refreshUser();
        Go.back();
        showSuccessToast(response);
        emit(state.copyWith(status: BaseStatus.success));
      },
      (error) {
        showErrorToast(error.message);
        emit(state.copyWith(status: BaseStatus.error));
      },
    );
  }

  //resendCodeApi

  Future<void> resendCode() async {
    final result = await baseCrudUseCase<BaseUser>(
      CrudBaseParams(
        api: getResnedApi(verifyType),
        httpRequestType: HttpRequestType.post,
        body: {'phone': phone, ...authBaseMap},
        mapper: (value) => BaseUser.fromJsonAuto(value),
      ),
    );
    result.when(
      (response) {
        showSuccessToast(
          LocaleKeys.verification_code_resended_successfully.tr(),
        );
        emit(state.copyWith(status: BaseStatus.success));
      },
      (error) {
        showErrorToast(error.message);
        emit(state.copyWith(status: BaseStatus.error));
      },
    );
  }

  Future<void> _changeUserLang() async {
    final lang = Go.context.locale.languageCode;
    await baseCrudUseCase(
      CrudBaseParams(
        api: changeLanguageApi,
        httpRequestType: HttpRequestType.patch,
        body: {'lang': lang, ...authBaseMap},
        mapper: (data) => data['msg'],
      ),
    );
  }
```
#### 2. استخدام UserCubit في UI
```dart
class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit()..getUsers(), // جلب البيانات عند الفتح
      child: Scaffold(
        appBar: AppBar(title: Text('المستخدمين')),
        body: BlocBuilder<UserCubit, AsyncState<List<User>>>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (state.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('حدث خطأ: ${state.errorMessage}'),
                    ElevatedButton(
                      onPressed: () => context.read<UserCubit>().getUsers(),
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            
            if (state.data.isEmpty) {
              return Center(child: Text('لا توجد بيانات'));
            }
            
            return ListView.builder(
              itemCount: state.data.length,
              itemBuilder: (context, index) {
                final user = state.data[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => context.read<UserCubit>().deleteUser(user.id),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // إضافة مستخدم جديد
            final newUser = User(
              id: DateTime.now().millisecondsSinceEpoch,
              name: 'مستخدم جديد',
              email: 'new@example.com',
            );
            context.read<UserCubit>().addUser(newUser);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

### BlocWidget Helper Classes

النظام بيوفر كمان helper classes عشان تسهل إنشاء الصفحات:

```dart
class UsersPageWithHelper extends BlocStatelessWidget<UserCubit> {
  @override
  UserCubit get create => UserCubit()..getUsers();
  
  @override
  Widget buildContent(BuildContext context, UserCubit cubit) {
    return Scaffold(
      body: BlocBuilder<UserCubit, AsyncState<List<User>>>(
        builder: (context, state) {
          // نفس الكود اللي فوق
          return Container();
        },
      ),
    );
  }
}
```

### StatusBuilder - Widget مبسط لإدارة الحالات

`StatusBuilder` هو widget ذكي بيخلي التعامل مع حالات AsyncState أسهل بكتير، بدل ما تكتب if/else كتير في كل مكان.

#### كيفية عمل StatusBuilder
```dart
class StatusBuilder<T> extends StatelessWidget {
  final AsyncState<T> data;
  final String? errorMessage;
  final Widget Function(T data, BuildContext context) onSuccess;
  final Widget Function()? onFail;
  final Widget Function()? onLoading;
  
  @override
  Widget build(BuildContext context) {
    return data.status.when(
      onSuccess: () => onSuccess(data.data, context),
      onLoading: () => onLoading?.call() ?? Center(child: CustomLoading.showLoadingView()),
      onError: () => onFail?.call() ?? CenterErrorWidget(message: errorMessage ?? 'حدث خطأ'),
    );
  }
}
```

#### استخدام StatusBuilder في العملي

**بدلاً من كده (الطريقة التقليدية):**
```dart
BlocBuilder<UserCubit, AsyncState<List<User>>>(
  builder: (context, state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('حدث خطأ: ${state.errorMessage}'),
            ElevatedButton(
              onPressed: () => context.read<UserCubit>().getUsers(),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    
    if (state.data.isEmpty) {
      return Center(child: Text('لا توجد بيانات'));
    }
    
    return ListView.builder(
      itemCount: state.data.length,
      itemBuilder: (context, index) {
        final user = state.data[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      },
    );
  },
)
```

**استخدم كده (مع StatusBuilder):**
```dart
BlocBuilder<UserCubit, AsyncState<List<User>>>(
  builder: (context, state) {
    return StatusBuilder<List<User>>(
      data: state,
      onSuccess: (users, context) {
        if (users.isEmpty) {
          return Center(child: Text('لا توجد بيانات'));
        }
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        );
      },
      onLoading: () => Center(child: CircularProgressIndicator()),
      onFail: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('حدث خطأ: ${state.errorMessage}'),
            ElevatedButton(
              onPressed: () => context.read<UserCubit>().getUsers(),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  },
)
```

#### مثال أكثر تفصيلاً مع StatusBuilder

```dart
class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit()..getProducts(),
      child: Scaffold(
        appBar: AppBar(title: Text('المنتجات')),
        body: BlocBuilder<ProductsCubit, AsyncState<List<Product>>>(
          builder: (context, state) {
            return StatusBuilder<List<Product>>(
              data: state,
              errorMessage: state.errorMessage,
              
              // في حالة النجاح
              onSuccess: (products, context) {
                return RefreshIndicator(
                  onRefresh: () => context.read<ProductsCubit>().getProducts(),
                  child: products.isEmpty
                      ? _buildEmptyState()
                      : _buildProductsList(products),
                );
              },
              
              // في حالة التحميل (اختياري - يمكن تركه فارغ للاستخدام الافتراضي)
              onLoading: () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل المنتجات...'),
                ],
              ),
              
              // في حالة الخطأ (اختياري)
              onFail: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'حدث خطأ غير متوقع',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<ProductsCubit>().getProducts(),
                      icon: Icon(Icons.refresh),
                      label: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد منتجات حالياً'),
        ],
      ),
    );
  }
  
  Widget _buildProductsList(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(product.image),
            ),
            title: Text(product.name),
            subtitle: Text('${product.price} ج.م'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // الانتقال لصفحة تفاصيل المنتج
            },
          ),
        );
      },
    );
  }
}
```

#### CenterErrorWidget

كمان في widget جاهز للأخطاء:

```dart
class CenterErrorWidget extends StatelessWidget {
  const CenterErrorWidget({super.key, required this.message});
  final String message;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: context.textStyle.s14.regular.setHintColor,
      ),
    );
  }
}
```

#### مميزات StatusBuilder

1. **تقليل الكود**: مش محتاج تكتب if/else في كل مكان
2. **إعادة الاستخدام**: نفس المنطق يتكرر في كل الصفحات
3. **المرونة**: يمكن تخصيص كل حالة حسب احتياجاتك
4. **الوضوح**: الكود بقى أوضح وأسهل في القراءة
5. **التحكم الكامل**: يمكن ترك أي حالة فارغة لاستخدام التصميم الافتراضي

#### استخدام مبسط جداً

```dart
// EX
// للاستخدام السريع بدون تخصيص

StatusBuilder<String>(
  data: state,
  onSuccess: (message, context) => Text(message),
)
// هيستخدم التصميم الافتراضي للتحميل والأخطاء
```

## 2. شرح GetBaseEntityCubit (النمط المتخصص)

`GetBaseEntityCubit` هو نمط متخصص ومطور للتعامل مع الـ entities اللي بتورث من `BaseEntity`. مصمم خصيصاً للبيانات اللي بتحتوي على id و name مع إمكانية التوسع.

### مكونات GetBaseEntityCubit

#### الـ State
```dart
class GetBaseEntityState<T extends BaseEntity> extends Equatable {
  const GetBaseEntityState({required this.dataState});
  final Async<List<T>> dataState;
  
  GetBaseEntityState copyWith({Async<List<T>>? data}) {
    return GetBaseEntityState(dataState: data ?? this.dataState);
  }
}
```

#### الـ Cubit نفسه
```dart
@Injectable()
class GetBaseEntityCubit<T extends BaseEntity> extends Cubit<GetBaseEntityState> {
  GetBaseEntityCubit() : super(GetBaseEntityState(dataState: Async<List<T>>.initial()));
  
  late final GetBaseEntityUseCase getBaseEntityseCase;
  
  // جلب البيانات باستخدام Path Parameters
  Future<void> fGetBaseNameAndId({int? id, bool idIsRequired = false}) async {
    if (idIsRequired && id == null) return;
    
    emit(state.copyWith(data: Async<List<T>>.loading()));
    final result = await getBaseEntityseCase<T>(
      GetBaseEntityParams(id: id, paramsType: ParamsType.path)
    );
    
    result.when(
      (data) => emit(state.copyWith(data: Async<List<T>>.success(data))),
      (failure) => emit(state.copyWith(data: Async<List<T>>.failure(failure))),
    );
  }
  
  // جلب البيانات باستخدام Query Parameters
  Future<void> fGetBaseNameAndIdWithQuery({required GetBaseEntityParams params}) async {
    emit(state.copyWith(data: Async<List<T>>.loading()));
    final result = await getBaseEntityseCase<T>(params);
    
    result.when(
      (data) => emit(state.copyWith(data: Async<List<T>>.success(data))),
      (failure) => emit(state.copyWith(data: Async<List<T>>.failure(failure))),
    );
  }
}
```

### إعداد النظام للعمل

#### 1. إنشاء Entity
```dart
class CategoryEntity extends BaseIdAndNameEntity {
  final String? description;
  final String? image;
  final bool isActive;
  
  const CategoryEntity({
    required super.id,
    required super.name,
    this.description,
    this.image,
    this.isActive = true,
  });
  
  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'is_active': isActive,
    };
  }
}
```

#### 2. تسجيل API Paths
```dart
String getBaseIdAndNameEntityApi<T extends BaseEntity>(GetBaseEntityParams? params) {
  final Map<Type, String Function(GetBaseEntityParams?)> apiPaths = {
    CategoryEntity: (params) => params?.id != null 
        ? "branches/${params!.id}/categories" 
        : "categories",
    PaymentMethodEntity: (params) => "branches/${params!.id}/payMethods",
    MealEntity: (params) => "branches/${params!.id}/meals",
    RegionEntity: (_) => "regions",
    CityEntity: (params) => "regions/${params!.id}/cities",
    BranchEntity: (params) => "cities/${params!.id}/branches",
  };
  
  if (T == BaseEntity) {
    throw UnsupportedError(
      'Cannot call API for the base class BaseEntity. Use a concrete subclass instead.'
    );
  }
  
  final pathBuilder = apiPaths[T];
  if (pathBuilder == null) {
    throw UnsupportedError('API path for type $T is not defined in apiPaths map.');
  }
  
  return pathBuilder(params);
}
```

#### 3. تسجيل JSON Mappers
```dart
T baseIdAndNameEntityFromJson<T>(Map<String, dynamic> json) {
  if (T == CategoryEntity) {
    return CategoryEntity.fromJson(json) as T;
  } else if (T == PaymentMethodEntity) {
    return PaymentMethodEntity.fromJson(json) as T;
  } else if (T == MealEntity) {
    return MealEntity.fromJson(json) as T;
  } else if (T == RegionEntity) {
    return RegionEntity.fromJson(json) as T;
  } else if (T == CityEntity) {
    return CityEntity.fromJson(json) as T;
  } else if (T == BranchEntity) {
    return BranchEntity.fromJson(json) as T;
  }
  
  throw UnsupportedError('Type $T is not supported. Please add fromJson function');
}
```

### أمثلة عملية للاستخدام

#### مثال 1: قائمة الفئات البسيطة
```dart
class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetBaseEntityCubit<CategoryEntity>()
        ..fGetBaseNameAndId(), // جلب كل الفئات
      child: Scaffold(
        appBar: AppBar(title: Text('الفئات')),
        body: BlocBuilder<GetBaseEntityCubit<CategoryEntity>, GetBaseEntityState>(
          builder: (context, state) {
            if (state.dataState.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (state.dataState.isFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('خطأ: ${state.dataState.errorMessage}'),
                    ElevatedButton(
                      onPressed: () => context.read<GetBaseEntityCubit<CategoryEntity>>()
                          .fGetBaseNameAndId(),
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            
            if (state.dataState.isSuccess) {
              final categories = state.dataState.data!;
              
              if (categories.isEmpty) {
                return Center(child: Text('لا توجد فئات'));
              }
              
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: category.image != null 
                        ? CircleAvatar(backgroundImage: NetworkImage(category.image!))
                        : CircleAvatar(child: Text(category.name[0])),
                    title: Text(category.name),
                    subtitle: category.description != null 
                        ? Text(category.description!)
                        : null,
                    trailing: category.isActive 
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.red),
                  );
                },
              );
            }
            
            return Container();
          },
        ),
      ),
    );
  }
}
```

#### مثال 2: فئات فرع معين مع Query Parameters
```dart
class BranchCategoriesPage extends StatelessWidget {
  final int branchId;
  
  const BranchCategoriesPage({required this.branchId});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetBaseEntityCubit<CategoryEntity>()
        ..fGetBaseNameAndIdWithQuery(
          params: GetBaseEntityParams(
            id: branchId,
            paramsType: ParamsType.query,
            queryParameters: {
              'scope': 'types',
              'type': 'meals',
              'all': 'false',
              'active_only': 'true',
            },
          ),
        ),
      child: Scaffold(
        appBar: AppBar(title: Text('فئات الفرع')),
        body: BlocBuilder<GetBaseEntityCubit<CategoryEntity>, GetBaseEntityState>(
          builder: (context, state) {
            return StatusBuilder<List<CategoryEntity>>(
              data: AsyncState(
                status: state.dataState.isLoading ? BaseStatus.loading :
                        state.dataState.isSuccess ? BaseStatus.success :
                        state.dataState.isFailure ? BaseStatus.error : BaseStatus.initial,
                data: state.dataState.data ?? [],
                errorMessage: state.dataState.errorMessage,
              ),
              onSuccess: (categories, context) {
                return RefreshIndicator(
                  onRefresh: () => context.read<GetBaseEntityCubit<CategoryEntity>>()
                      .fGetBaseNameAndIdWithQuery(
                        params: GetBaseEntityParams(
                          id: branchId,
                          paramsType: ParamsType.query,
                          queryParameters: {
                            'scope': 'types',
                            'type': 'meals',
                            'all': 'false',
                            'active_only': 'true',
                          },
                        ),
                      ),
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            category.image != null
                                ? Image.network(category.image!, height: 60)
                                : Icon(Icons.category, size: 60),
                            SizedBox(height: 8),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (category.description != null)
                              Text(
                                category.description!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

#### مثال 3: Dropdown للمدن والمناطق
```dart
class CityRegionDropdowns extends StatefulWidget {
  @override
  _CityRegionDropdownsState createState() => _CityRegionDropdownsState();
}

class _CityRegionDropdownsState extends State<CityRegionDropdowns> {
  RegionEntity? selectedRegion;
  CityEntity? selectedCity;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown المناطق
        BlocProvider(
          create: (context) => GetBaseEntityCubit<RegionEntity>()
            ..fGetBaseNameAndId(),
          child: BlocBuilder<GetBaseEntityCubit<RegionEntity>, GetBaseEntityState>(
            builder: (context, state) {
              if (state.dataState.isLoading) {
                return DropdownButtonFormField<RegionEntity>(
                  decoration: InputDecoration(labelText: 'جاري التحميل...'),
                  items: [],
                  onChanged: null,
                );
              }
              
              if (state.dataState.isSuccess) {
                final regions = state.dataState.data!;
                return DropdownButtonFormField<RegionEntity>(
                  decoration: InputDecoration(labelText: 'اختر المنطقة'),
                  value: selectedRegion,
                  items: regions.map((region) {
                    return DropdownMenuItem<RegionEntity>(
                      value: region,
                      child: Text(region.name),
                    );
                  }).toList(),
                  onChanged: (region) {
                    setState(() {
                      selectedRegion = region;
                      selectedCity = null; // إعادة تعيين المدينة
                    });
                  },
                );
              }
              
              return DropdownButtonFormField<RegionEntity>(
                decoration: InputDecoration(labelText: 'خطأ في تحميل المناطق'),
                items: [],
                onChanged: null,
              );
            },
          ),
        ),
        
        SizedBox(height: 16),
        
        // Dropdown المدن
        if (selectedRegion != null)
          BlocProvider(
            create: (context) => GetBaseEntityCubit<CityEntity>()
              ..fGetBaseNameAndId(id: selectedRegion!.id, idIsRequired: true),
            child: BlocBuilder<GetBaseEntityCubit<CityEntity>, GetBaseEntityState>(
              builder: (context, state) {
                if (state.dataState.isLoading) {
                  return DropdownButtonFormField<CityEntity>(
                    decoration: InputDecoration(labelText: 'جاري تحميل المدن...'),
                    items: [],
                    onChanged: null,
                  );
                }
                
                if (state.dataState.isSuccess) {
                  final cities = state.dataState.data!;
                  return DropdownButtonFormField<CityEntity>(
                    decoration: InputDecoration(labelText: 'اختر المدينة'),
                    value: selectedCity,
                    items: cities.map((city) {
                      return DropdownMenuItem<CityEntity>(
                        value: city,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (city) {
                      setState(() {
                        selectedCity = city;
                      });
                    },
                  );
                }
                
                return DropdownButtonFormField<CityEntity>(
                  decoration: InputDecoration(labelText: 'خطأ في تحميل المدن'),
                  items: [],
                  onChanged: null,
                );
              },
            ),
          ),
      ],
    );
  }
}
```

### مميزات GetBaseEntityCubit

#### 1. النمط الموحد
```dart
// EX
// نفس الطريقة لكل الـ entities
final categoryCubit = GetBaseEntityCubit<CategoryEntity>();
final regionsCubit = GetBaseEntityCubit<RegionEntity>();
final citiesCubit = GetBaseEntityCubit<CityEntity>();
```

#### 2. Generic Type Safety
```dart
// EX
// الـ Cubit بيضمن إن النوع صحيح في كل مرحلة
GetBaseEntityCubit<CategoryEntity> // هيرجع List<CategoryEntity> بس
GetBaseEntityCubit<RegionEntity>   // هيرجع List<RegionEntity> بس
```

#### 3. إدارة Parameters مرنة
```dart
// Path Parameters
cubit.fGetBaseNameAndId(id: 123);

// Query Parameters
cubit.fGetBaseNameAndIdWithQuery(
  params: GetBaseEntityParams(
    id: 123,
    paramsType: ParamsType.query,
    queryParameters: {'active': 'true', 'limit': '50'},
  ),
);
```

#### 4. Custom Mappers
```dart
// EX
// يمكن تمرير mapper مخصوص
GetBaseEntityParams<CategoryEntity>(
  mapper: (json) => (json['categories'] as List)
      .map((e) => CategoryEntity.fromJson(e))
      .toList(),
);
```

## نظرة عامة على النظام الكامل

النظام ده مبني على **Clean Architecture** و **Generic Programming** عشان يوفر حل موحد للتعامل مع العمليات الأساسية (CRUD) وجلب البيانات من الـ API بطريقة قابلة لإعادة الاستخدام.

## هيكل النظام (Architecture Flow)

```
Presentation Layer (Cubit) 
    ↓
Domain Layer (Use Cases) 
    ↓
Domain Layer (Repository Interface)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Layer (Remote Data Source)
    ↓
Network Service
```

## المكونات الأساسية

### 1. Domain Layer (طبقة المنطق)

#### BaseEntity
```dart
class BaseEntity extends Equatable {
  const BaseEntity();
  @override
  List<Object?> get props => [];
}
```
- دي الكلاس الأساسي اللي كل الـ entities بتورث منه
- بيستخدم `Equatable` عشان المقارنة بين الكائنات

#### BaseIdAndNameEntity
```dart
class BaseIdAndNameEntity extends BaseEntity {
  final int id;
  final String name;
  const BaseIdAndNameEntity({required this.id, required this.name});
}
```
- كلاس مخصوص للـ entities اللي بتحتوي على id و name بس
- مفيد للـ dropdowns والقوائم البسيطة

#### Async Class (إدارة حالات التحميل)
```dart
class Async<T> extends Equatable {
  final T? data;
  final Failure? failure;
  final bool _successWithoutData;
  final bool? _loading;
  
  bool get isLoading => _loading ?? false;
  bool get isSuccess => (_successWithoutData || data != null) && (failure == null);
  bool get isFailure => failure != null;
  bool get isInitial => // منطق التحقق من الحالة الأولية
}
```

**الحالات المختلفة:**
- `Async.initial()` - الحالة الأولية
- `Async.loading()` - أثناء التحميل
- `Async.success(data)` - نجح وفيه بيانات
- `Async.successWithoutData()` - نجح بدون بيانات
- `Async.failure(failure)` - فشل مع رسالة خطأ

### 2. Use Cases (حالات الاستخدام)

#### GetBaseEntityUseCase
```dart
@Injectable()
class GetBaseEntityUseCase {
  final BaseRepository repository;
  
  Future<Result<List<T>, Failure>> call<T extends BaseEntity>(
      GetBaseEntityParams? param) async {
    return await repository.getBaseIdAndNameEntity<T>(param);
  }
}
```

**معاملات البحث:**
```dart
class GetBaseEntityParams<T extends BaseIdAndNameEntity> {
  final int? id;
  final ParamsType paramsType; // path أو query
  final Map<String, dynamic> queryParameters;
  final T Function<T>(Map<String, dynamic> json)? mapper;
}
```

#### BaseCrudUseCase
```dart
@Injectable()
class BaseCrudUseCase {
  final BaseRepository repository;
  
  Future<Result<T, Failure>> call<T extends CrudResponse>(
      CrudBaseParmas param) async {
    return await repository.crudCall<T>(param);
  }
}
```

**أنواع العمليات المدعومة:**
```dart
enum CrudEnum {
  getAll(requestMethod: RequestMethod.get),
  getDetails(requestMethod: RequestMethod.get),
  add(requestMethod: RequestMethod.post),
  updateWithPost(requestMethod: RequestMethod.post),
  put(requestMethod: RequestMethod.put),
  delete(requestMethod: RequestMethod.delete);
}
```

### 3. Data Layer (طبقة البيانات)

#### BaseRemoteDataSource
```dart
abstract class BaseRemoteDataSource {
  Future<List<T>> getData<T extends BaseEntity>(GetBaseEntityParams? param);
  Future<T> crudCall<T extends CrudResponse>(CrudBaseParmas param);
}
```

#### BaseRepository
```dart
abstract class BaseRepository {
  Future<Result<List<T>, Failure>> getBaseIdAndNameEntity<T extends BaseEntity>(
      GetBaseEntityParams? param);
  Future<Result<T, Failure>> crudCall<T extends CrudResponse>(
      CrudBaseParmas params);
}
```

### 4. Presentation Layer (طبقة العرض)

#### GetBaseEntityCubit
```dart
@Injectable()
class GetBaseEntityCubit<T extends BaseEntity> extends Cubit<GetBaseEntityState> {
  late final GetBaseEntityUseCase getBaseEntityseCase;
  
  Future<void> fGetBaseNameAndId({int? id, bool idIsRequired = false}) async {
    // تنفيذ جلب البيانات باستخدام Path Parameters
  }
  
  Future<void> fGetBaseNameAndIdWithQuery({
    required GetBaseEntityParams params
  }) async {
    // تنفيذ جلب البيانات باستخدام Query Parameters
  }
}
```

## شرح الـ Generics في النظام

### 1. Generic في الـ Cubit
```dart
GetBaseEntityCubit<CategoryEntity>
```
- `T extends BaseEntity` معناها إن T لازم يكون من نوع BaseEntity أو يورث منه
- ده بيخلي الـ Cubit يشتغل مع أي نوع من الـ entities

### 2. Generic في الـ Use Cases
```dart
Future<Result<List<T>, Failure>> call<T extends BaseEntity>()
```
- بيرجع قائمة من النوع T أو Failure
- T مقيد بـ BaseEntity

### 3. Generic في الـ Repository
```dart
Future<List<T>> getData<T extends BaseEntity>()
```
- بيتعامل مع أي نوع من البيانات اللي بتورث من BaseEntity

## طرق الاستخدام العملي

### 1. إنشاء Entity جديد
```dart
class CategoryEntity extends BaseIdAndNameEntity {
  final String? description;
  
  const CategoryEntity({
    required super.id,
    required super.name,
    this.description,
  });
  
  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
```

### 2. تسجيل الـ API Path
```dart
String getBaseIdAndNameEntityApi<T extends BaseEntity>(GetBaseEntityParams? params) {
  final Map<Type, String Function(GetBaseEntityParams?)> apiPaths = {
    CategoryEntity: (_) => "filters/resource/branches/${params!.id}/categories",
    PaymentMethodEntity: (_) => "filters/branches/${params!.id}/payMethods",
    MealEntity: (_) => "branches/${params!.id}/meals",
    RegionEntity: (_) => "regions",
  };
  
  final pathBuilder = apiPaths[T];
  if (pathBuilder == null) {
    throw UnsupportedError('API path for type $T is not defined');
  }
  return pathBuilder(params);
}
```

### 3. تسجيل الـ JSON Mapper
```dart
T baseIdAndNameEntityFromJson<T>(Map<String, dynamic> json) {
  if (T == CategoryEntity) {
    return CategoryEntity.fromJson(json) as T;
  } else if (T == PaymentMethodEntity) {
    return PaymentMethodEntity.fromJson(json) as T;
  }
  
  throw UnsupportedError('Type $T is not supported');
}
```

### 4. استخدام الـ Cubit في الـ UI
```dart
// EX
// في الـ Widget
BlocProvider(
  create: (context) => GetBaseEntityCubit<CategoryEntity>(),
  child: BlocBuilder<GetBaseEntityCubit<CategoryEntity>, GetBaseEntityState>(
    builder: (context, state) {
      return FloatingActionButton(
        onPressed: () {
          final cubit = context.read<GetBaseEntityCubit<CategoryEntity>>();
          
          // استخدام Path Parameters
          cubit.fGetBaseNameAndId(id: 39, idIsRequired: true);
          
          // أو استخدام Query Parameters
          cubit.fGetBaseNameAndIdWithQuery(
            params: GetBaseEntityParams(
              id: 39,
              paramsType: ParamsType.query,
              queryParameters: {
                'scope': 'types',
                'type': 'meals',
                'all': 'false',
              },
            ),
          );
        },
        child: state.dataState.isLoading
            ? CircularProgressIndicator()
            : state.dataState.isSuccess
                ? Text(state.dataState.data?.first.name ?? '')
                : Icon(Icons.add),
      );
    },
  ),
)
```

## مميزات النظام

### 1. قابلية إعادة الاستخدام
- مرة واحدة تكتب الكود، تستخدمه مع أي entity
- مش محتاج تكرر نفس الكود لكل نوع بيانات

### 2. Type Safety
- الـ Generics بتضمن إن النوع صحيح في كل مرحلة
- مش هتحصل على خطأ في وقت التشغيل بسبب النوع الغلط

### 3. سهولة الصيانة
- لو عايز تغير حاجة في المنطق، هتغيرها في مكان واحد
- الكود منظم ومفصول حسب المسئوليات

### 4. إدارة محكمة للحالات
- الـ Async class بيدير كل حالات التطبيق بوضوح
- سهل تتبع حالة التحميل والأخطاء

## نصائح للاستخدام

### 1. إضافة Entity جديد
1. اعمل extend للـ BaseEntity أو BaseIdAndNameEntity
2. سجل الـ API path في `getBaseIdAndNameEntityApi`
3. سجل الـ JSON mapper في `baseIdAndNameEntityFromJson`
4. استخدم الـ Cubit مع النوع الجديد

### 2. التعامل مع الأخطاء
```dart
if (state.dataState.isFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.dataState.errorMessage ?? 'خطأ غير معروف')),
  );
}
```

### 3. التحكم في التحميل
```dart
if (state.dataState.isLoading) {
  return CircularProgressIndicator();
}
```

# injectable

استخدمنا ال injectable package بدل من ال get it 
هي مبنية عليها وبتعمل نفس كل حاجة بس الفرق انها مجرد بتعمل نوتاشن فوق الكلاسيس وبتعمل جينيرات للكود 
بترن بس كوماند ال build runner مع كل حاجة ضفتها محتاج فيها 
يحصل inject

هيطلعلك في الفايل الي اتعمله  الي معمولة جينيارت ايرورو في 
GetBaseEntityUseCase<Genaric> 
شيل <Genaric> وهتظبط

#### pub dev
[injectable](https://pub.dev/packages/injectable)


## الخلاصة

النظام ده بيوفر foundation قوي للتعامل مع البيانات في التطبيق بطريقة منظمة وقابلة للصيانة. الـ Generics بتخلي الكود مرن وآمن في نفس الوقت، والـ Clean Architecture بتضمن إن كل جزء في النظام له مسئولية واضحة ومحددة.

# Thanks
Many thanks to Ahmed Salah for the inspiring ideas and great collaboration.