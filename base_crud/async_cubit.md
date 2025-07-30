
# 📄 async_cubit.dart

## 🧠 Overview
This file defines a generic and reusable asynchronous `Cubit` called `AsyncCubit<T>`, with built-in state management (`AsyncState<T>`) to handle common states: initial, loading, success, and error.

It also provides a reusable widget structure for using this cubit in both `StatelessWidget` and `StatefulWidget` forms.

---

## ✅ `AsyncCubit<T>`

A base class for Cubits that need to manage async operations.

### 🔹 Key Methods
- `setLoading()` — Set state to loading.
- `setSuccess({required T data})` — Emit success state.
- `setError({String? errorMessage, bool showToast = false})` — Emit error with optional toast.
- `executeAsync(...)` — Execute an async function and manage loading/success/error automatically.

```dart
Future<void> executeAsync({
  required Future<Result<T, Failure>> Function() operation,
  Function(T)? successEmitter,
});
```

---

## ✅ `AsyncState<T>`

Wraps the state of the Cubit.

### 🔹 Fields:
- `status`: enum of `BaseStatus` (initial, loading, success, error, loadingMore).
- `data`: Generic type `T`.
- `errorMessage`: Optional string for error info.

### 🔹 Helper Getters:
- `isInitial`, `isLoading`, `isSuccess`, `isError`, `isLoadingMore`

### 🔹 Example:
```dart
final state = AsyncState<String>.loading(data: "previous");
```

---

## ✅ `BlocStatelessWidget<C extends AsyncCubit>`

A reusable base class for stateless widgets using a Cubit.

```dart
abstract class BlocStatelessWidget<C extends AsyncCubit>
```

- `create`: override to provide your Cubit instance.
- `buildContent`: implement UI using the Cubit.

---

## ✅ `BlocStatefulWidget<C extends AsyncCubit>`

Like `BlocStatelessWidget` but for stateful scenarios.

- `create`: override to provide your Cubit.
- `initState` & `dispose`: optional lifecycle hooks.
- `buildContent`: your widget body with access to Cubit and `State`.

---

## 🧪 Example Usage

```dart
class MyWidget extends BlocStatelessWidget<MyCubit> {
  @override
  MyCubit get create => MyCubit();

  @override
  Widget buildContent(BuildContext context, MyCubit cubit) {
    return BlocBuilder<MyCubit, AsyncState<MyData>>(
      builder: (context, state) {
        if (state.isLoading) return CircularProgressIndicator();
        if (state.isError) return Text("Error: ${state.errorMessage}");
        return Text("Data: ${state.data}");
      },
    );
  }
}
```
