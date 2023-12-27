import 'package:mvvm_fire_app/model/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'form_viewmodel.g.dart';

@riverpod
class FormViewModel extends _$FormViewModel {

  @override
  List<TodoState> build() {
    return [];
  }

  void addTitle(String titleValue) {
    state = [...state, TodoState(title: titleValue)];
  }
}
