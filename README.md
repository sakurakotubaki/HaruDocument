# AsyncNotifierとNotifierについて

## AsyncNotifierの場合:
## 🧑‍🎓公式の文章を日本語にするとこんな感じか?
これは非同期に初期化されるNotifierの実装です。

これはFutureProviderに似ていますが、公開メソッドを定義することで副作用を実行することができます。

主に以下のような用途で使用されます：

ネットワークリクエストをキャッシュしつつ、副作用を実行できるようにします。例えば、ビルドは現在の「ユーザー」に関する情報を取得できます。そして、AsyncNotifierは「setName」のようなメソッドを公開し、現在のユーザー名を変更できるようにします。
非同期のデータソースからNotifierを初期化します。例えば、ローカルデータベースからNotifierの初期状態を取得するなどです。


## 副作用とは
関数やメソッドが自身のスコープ外で何らかの変更を行うことを指します。具体的には以下のような操作が含まれます：

1. 外部の変数を変更する
2. データベースやファイルに書き込む
3. ネットワークリクエストを送信する
4. 画面に何かを描画する

これらの操作は、関数やメソッドの実行結果がその入力だけでなく、それらの副作用にも依存することを意味します。そのため、副作用はプログラムの振る舞いを予測しにくくする可能性があります。しかし、副作用は避けられない場合も多く、その場合は適切に管理することが重要です。

データは、AsyncValueで返ってくるので、データを表示するときは、`when`,`error`,`loadding`の３つを使う。
riverpod3.0からは、switchで書くのが推奨されるとのこと。

データ型は、
Future型で書く。Streamは使えないので、StreamNotifierなるものを使う。

ViewModelなので、APIやDBを操作するロジックはレポジトリクラスに書くのが望ましい。こだわりすぎるとDTOとかまで分ける。

`ref.listen`でスナックバーやダイアログを出したいときに、ViewModelで状態を管理するのが良くある例。今回は省いてるけど。

今回の場合だと、`fetchTodos`しか使ってないけど、FutureProviderで普段やってることもできるんだな〜と使い道がわかったかもしれないなと思います。
```dart
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
```

View側でAPIやDBのデータを表示するときは、`ref.watch`してUIに描画する処理を書く。
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_fire_app/presentation/todo_edit.dart';
import 'package:mvvm_fire_app/presentation/todo_form.dart';
import 'package:mvvm_fire_app/presentation/todo_view_model.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoViewModel = ref.watch(todoViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TodoForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: todoViewModel.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
        data: (db) => ListView.builder(
          itemCount: db.length,
          itemBuilder: (context, index) {
            final todo = db[index];
            return ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TodoEdit(
                      todoState: todo,
                    ),
                  ),
                );
              },
              title: Text(todo.title),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await ref.read(todoViewModelProvider.notifier).deleteTodo(
                        todo.id,
                      );
                  ref.invalidate(todoViewModelProvider); // 強制的に画面を更新する
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

```


## Notifier
これは、StatefulWidgetの`setState`の代わりに状態の管理をして、画面の更新をするユースケースで使う。flutter_hooksだと、`useState`ですね。

[比較する記事書いてみた](https://zenn.dev/joo_hashi/articles/3b51d5f9d011cb)

使用例、ハートのtoggleボタン:
```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hook_notifier.g.dart';

@riverpod
class HookNotifier extends _$HookNotifier {

  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

class HookNotifierView extends HookConsumerWidget {
  const HookNotifierView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Hook Notifier'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Like State: ${ref.watch(hookNotifierProvider)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            GestureDetector(
              onDoubleTap: () {
                ref.read(hookNotifierProvider.notifier).toggle();
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Double Tap to Like',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(hookNotifierProvider.notifier).toggle();
              },
              icon: Icon(
                ref.watch(hookNotifierProvider)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: ref.watch(hookNotifierProvider) ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
