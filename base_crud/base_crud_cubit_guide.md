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
  
  // إضافة مستخدم جديد
  Future<void> addUser(User newUser) async {
    await executeAsync(
      operation: () => baseCrudUseCase<User>(
        CrudBaseParmas(
          api: "users",
          httpRequestType: HttpRequestType.post,
          body: newUser.toJson(),
          mapper: (json) => User.fromJson(json),
        ),
      ),
      successEmitter: (addedUser) {
        // إضافة المستخدم للقائمة الحالية
        final currentUsers = List<User>.from(state.data);
        currentUsers.add(addedUser);
        updateData(currentUsers);
      },
    );
  }
  
  // حذف مستخدم
  Future<void> deleteUser(int userId) async {
    await executeAsync(
      operation: () => baseCrudUseCase<Map<String, dynamic>>(
        CrudBaseParmas(
          api: "users/$userId",
          httpRequestType: HttpRequestType.delete,
          mapper: (json) => json as Map<String, dynamic>,
        ),
      ),
      successEmitter: (_) {
        // إزالة المستخدم من القائمة
        final currentUsers = state.data.where((user) => user.id != userId).toList();
        updateData(currentUsers);
      },
    );
  }
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
// للاستخدام السريع بدون تخصيص
StatusBuilder<String>(
  data: state,
  onSuccess: (message, context) => Text(message),
)

// هيستخدم التصميم الافتراضي للتحميل والأخطاء
```

## 2. مقارنة بين AsyncCubit والـ GetBaseEntityCubit التقليدي

| الخاصية | AsyncCubit (الجديد) | GetBaseEntityCubit (التقليدي) |
|---------|-------------------|----------------------------|
| **البساطة** | أبسط في الاستخدام والفهم | أكثر تعقيداً |
| **المرونة** | يدعم أي نوع من البيانات | مقيد بـ BaseEntity فقط |
| **إدارة الحالات** | إدارة محكمة مع حالات واضحة | يعتمد على Async class منفصل |
| **العمليات المدعومة** | جميع عمليات CRUD | محدود بـ GET operations أساساً |
| **معالجة الأخطاء** | مدمجة مع Toast | يحتاج معالجة يدوية |
| **الكود المطلوب** | أقل كود للتنفيذ | يحتاج setup أكثر |
| **Type Safety** | آمن للأنواع | آمن للأنواع |
| **قابلية إعادة الاستخدام** | عالية جداً | عالية لكن محدودة |

### مثال مقارن

#### الطريقة التقليدية (GetBaseEntityCubit)
```dart
// 1. إنشاء Entity
class CategoryEntity extends BaseIdAndNameEntity { /* ... */ }

// 2. تسجيل API Path
String getBaseIdAndNameEntityApi<T>() { /* ... */ }

// 3. تسجيل JSON Mapper
T baseIdAndNameEntityFromJson<T>() { /* ... */ }

// 4. استخدام في UI
BlocProvider(
  create: (c) => GetBaseEntityCubit<CategoryEntity>(),
  child: BlocBuilder<GetBaseEntityCubit<CategoryEntity>, GetBaseEntityState>(
    builder: (context, state) {
      if (state.dataState.isLoading) return CircularProgressIndicator();
      if (state.dataState.isFailure) return Text(state.dataState.errorMessage ?? '');
      if (state.dataState.isSuccess) {
        return ListView.builder(/* ... */);
      }
      return Container();
    },
  ),
)
```

#### الطريقة الجديدة (AsyncCubit)
```dart
// 1. إنشاء Cubit
class CategoryCubit extends AsyncCubit<List<Category>> {
  CategoryCubit() : super([]);
  
  Future<void> getCategories() async {
    await executeAsync(
      operation: () => baseCrudUseCase<List<Category>>(
        CrudBaseParmas(
          api: "categories",
          httpRequestType: HttpRequestType.get,
          mapper: (json) => (json as List).map((e) => Category.fromJson(e)).toList(),
        ),
      ),
    );
  }
}

// 2. استخدام في UI
BlocProvider(
  create: (c) => CategoryCubit()..getCategories(),
  child: BlocBuilder<CategoryCubit, AsyncState<List<Category>>>(
    builder: (context, state) {
      if (state.isLoading) return CircularProgressIndicator();
      if (state.isError) return Text(state.errorMessage ?? '');
      return ListView.builder(/* ... */);
    },
  ),
)
```

## متى تستخدم كل نمط؟

### استخدم AsyncCubit عندما:
- تحتاج مرونة أكبر في نوع البيانات
- تريد كود أبسط وأسرع في التطوير
- تحتاج عمليات CRUD متنوعة
- تريد معالجة أخطاء مدمجة

### استخدم GetBaseEntityCubit عندما:
- البيانات محدودة في BaseEntity
- تحتاج نمط موحد عبر التطبيق
- التطبيق كبير ويحتاج هيكلة صارمة
- الفريق يفضل Clean Architecture الكاملة

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

## الخلاصة

النظام ده بيوفر foundation قوي للتعامل مع البيانات في التطبيق بطريقة منظمة وقابلة للصيانة. الـ Generics بتخلي الكود مرن وآمن في نفس الوقت، والـ Clean Architecture بتضمن إن كل جزء في النظام له مسئولية واضحة ومحددة.