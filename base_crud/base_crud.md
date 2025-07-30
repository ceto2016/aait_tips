
# 📄 base_crud.dart

## 🧠 Overview
This file provides a generic CRUD use case and request structure that enables any data layer operation (GET, POST, PUT, DELETE, etc.) with a single reusable interface.

---

## ✅ BaseCrudUseCase

```dart
@LazySingleton()
class BaseCrudUseCase {
  final BaseRepository repository;

  BaseCrudUseCase({required this.repository});

  Future<Result<T, Failure>> call<T>(CrudBaseParmas param) async {
    return await repository.crudCall<T>(param);
  }
}
```

- A generic use case that abstracts the repository CRUD call.
- Returns a `Result<T, Failure>` that can be handled in the UI.

---

## ✅ HttpRequestType

```dart
enum HttpRequestType {
  get(requestMethod: RequestMethod.get),
  post(requestMethod: RequestMethod.post),
  put(requestMethod: RequestMethod.put),
  patch(requestMethod: RequestMethod.patch),
  delete(requestMethod: RequestMethod.delete);

  final RequestMethod requestMethod;
  const HttpRequestType({required this.requestMethod});
}
```

- Encapsulates standard HTTP methods.
- Associates each type with a `RequestMethod` enum.

---

## ✅ CrudBaseParmas<T>

```dart
class CrudBaseParmas<T> {
  final String api;
  final HttpRequestType httpRequestType;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? queryParameters;
  final T Function(dynamic) mapper;
  final bool isFromData;
  final void Function(int, int)? onSendProgress;

  CrudBaseParmas({
    required this.api,
    required this.httpRequestType,
    this.body,
    this.queryParameters,
    this.onSendProgress,
    this.isFromData = false,
    required this.mapper,
  });

  CrudBaseParmas<T> copyWith({
    String? api,
    HttpRequestType? httpRequestType,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? mapper,
    bool? isFromData,
  }) {
    return CrudBaseParmas<T>(
      api: api ?? this.api,
      httpRequestType: httpRequestType ?? this.httpRequestType,
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      mapper: mapper ?? this.mapper,
      isFromData: isFromData ?? this.isFromData,
    );
  }
}
```

### 🔸 Parameters:
- `api`: The endpoint URL.
- `httpRequestType`: Type of HTTP request.
- `body`: Optional body for POST/PUT.
- `queryParameters`: Optional URL query.
- `mapper`: A function to transform the raw response.
- `isFromData`: Use FormData (for file uploads, etc).
- `onSendProgress`: Optional progress tracking.

---

## 🧪 Example

```dart
final result = await baseCrudUseCase.call<MyModel>(
  CrudBaseParmas(
    api: '/products',
    httpRequestType: HttpRequestType.post,
    body: {
      'name': 'Cucumber',
      'price': 10,
    },
    mapper: (json) => MyModel.fromJson(json),
  ),
);
```
