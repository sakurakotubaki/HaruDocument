import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_fire_app/data/firebase/firestore_provider.dart';
import 'package:mvvm_fire_app/model/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'todo_repository.g.dart';

// Todoのabstractクラス
abstract class TodoRepository {
  Future<List<TodoState>> fetchTodos();
  Future<void> addTodo(TodoState todoState);
  Future<void> updateTodo(String id, String updateController);
  Future<void> deleteTodo(String id);
}

@Riverpod(keepAlive: true)
TodoRepositoryImpl todoRepositoryImpl(TodoRepositoryImplRef ref) {
  return TodoRepositoryImpl(ref: ref);
}

// Todoのリポジトリクラス
class TodoRepositoryImpl implements TodoRepository {
  final Ref ref;
  TodoRepositoryImpl({required this.ref});

  @override
  Future<void> addTodo(TodoState todoState) async {
    try {
      await ref.read(todoReferenceProvider).add(todoState);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<TodoState>> fetchTodos() async {
    try {
      final snapshot = await ref.read(todoReferenceProvider).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateTodo(id, updateController) async {
    try {
      await ref.read(todoReferenceProvider).doc(id).update({'title': updateController});
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteTodo(id) async {
    try {
      await ref.read(todoReferenceProvider).doc(id).delete();
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
