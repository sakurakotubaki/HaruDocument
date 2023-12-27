import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvvm_fire_app/model/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'firestore_provider.g.dart';

// FirebaseFirestoreをインスタンス化するためのProvider
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}
// withConverterを使って、FirestoreのデータをTodoStateに変換するプロバイダー
@riverpod
CollectionReference<TodoState> todoReference(TodoReferenceRef ref) {
  return ref.watch(firebaseFirestoreProvider).collection('todo').withConverter(fromFirestore: (snapshot, _) {
    final data = snapshot.data()!;
    final id = snapshot.id;
    // データがない場合は、空のUserをidだけセットして返す
    if (data.isEmpty) return const TodoState(id: '', title: '');
    data['id'] = id;
    return TodoState.fromJson(data);
  }, toFirestore: (todo, _) {
    return todo.toJson();
  });
}
