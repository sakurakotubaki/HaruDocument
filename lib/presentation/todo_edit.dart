import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_fire_app/model/todo_state.dart';
import 'package:mvvm_fire_app/presentation/todo_view_model.dart';

class TodoEdit extends ConsumerWidget {
  const TodoEdit({super.key, required this.todoState});

  final TodoState todoState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateController = TextEditingController(text: todoState.title);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Form'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: updateController,
              decoration: const InputDecoration(
                hintText: 'やることを入力してください',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(todoViewModelProvider.notifier)
                    .updateTodo(todoState.id, updateController.text);
                ref.invalidate(todoViewModelProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }
}
