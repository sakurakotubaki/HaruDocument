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
