import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_fire_app/model/todo_state.dart';
import 'package:mvvm_fire_app/presentation/todo_view_model.dart';

class TodoForm extends ConsumerWidget {
  const TodoForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Form'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: todoController,
              decoration: const InputDecoration(
                hintText: 'やることを入力してください',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                var todoState =
                    const TodoState().copyWith(title: todoController.text);
                await ref
                    .read(todoViewModelProvider.notifier)
                    .addTodo(todoState);
                ref.invalidate(todoViewModelProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
