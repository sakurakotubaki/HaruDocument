import 'package:mvvm_fire_app/data/repository/todo_repository.dart';
import 'package:mvvm_fire_app/model/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'todo_view_model.g.dart';

// FutureProviderの代わりにAsyncNotifierでデータを取得する
@riverpod
class TodoViewModel extends _$TodoViewModel {
  @override
  FutureOr<List<TodoState>> build() {
    return fetchTodos();
  }

  // レポジトリのメソッドをViewModelで呼び出す
  Future<List<TodoState>> fetchTodos() async {
    try {
      final snapshot = await ref.read(todoRepositoryImplProvider).fetchTodos();
      return snapshot;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  // 追加するメソッド
  Future<void> addTodo(TodoState todoState) async {
    try {
      await ref.read(todoRepositoryImplProvider).addTodo(todoState);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  // 更新するメソッド
  Future<void> updateTodo(String id, String updateController) async {
    try {
      await ref.read(todoRepositoryImplProvider).updateTodo(
            id,
            updateController,
          );
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  // 削除するメソッド
  Future<void> deleteTodo(String id) async {
    try {
      await ref.read(todoRepositoryImplProvider).deleteTodo(
            id,
          );
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
