import 'package:first_app/Controller/database_helper.dart';
import 'package:first_app/Model/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class TodosRepo {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final void Function() onTodosLoaded;
  // final _textController = TextEditingController();
  // final _descriptionTextController = TextEditingController();
  // String _selectedCategoryValue = "";
  // DateTime dateTime = DateTime.now();
  final List<String> _categories = ["Gündelik", "İş", "Okul"];
  List<TodoModel> todoItems = [];
  var log = Logger();

  TodosRepo({
    required this.onTodosLoaded,
  });

  // TextEditingController get textController => _textController;
  // TextEditingController get descriptionTextController =>
  //     _descriptionTextController;

  // String get selectedCategoryValue => _selectedCategoryValue;

  // TextEditingController? get textEditingController => null;

  // set selectedCategoryValue(String value) {
  //   _selectedCategoryValue = value;
  // }

  List<String> get categories => _categories;

  Future<List<TodoModel>> loadTodos() async {
    final todos = await _databaseHelper.getTodos();
    todoItems = todos;
    onTodosLoaded();
    return todoItems;
  }

  Future<void> saveTask(
      TextEditingController textController,
      TextEditingController descriptionTextController,
      String selectedCategoryValue,
      DateTime dateTime) async {
    if (textController.text.isNotEmpty &&
        descriptionTextController.text.isNotEmpty) {
      final todo = TodoModel(
        id: null,
        taskName: textController.text,
        taskCompleted: false,
        isVisible: true,
        taskDescription: descriptionTextController.text,
        taskDate: dateTime,
        taskCategory: selectedCategoryValue,
      );
      try {
        log.i(todoItems.indexed);

        await _databaseHelper.insertTodo(todo);
        clearAddingTodoFields(textController, descriptionTextController,
            selectedCategoryValue, dateTime);
        await loadTodos();
      } catch (e) {
        log.e('Error inserting todo: $e');
      }
    }
  }

  void checkBoxChanged(int index) async {
    final todo = todoItems[index];
    final updatedTodo = TodoModel(
      id: todo.id,
      taskName: todo.taskName,
      taskCompleted: !todo.taskCompleted,
      isVisible: true,
      taskDescription: todo.taskDescription,
      taskDate: todo.taskDate,
      taskCategory: todo.taskCategory,
    );
    await _databaseHelper.updateTodo(updatedTodo);
    await loadTodos();

    await Future.delayed(const Duration(seconds: 1));
    // await deleteTask(todo);
    await loadTodos();
    // setState(() {});
  }

  Future<void> deleteTask(TodoModel todo) async {
    final updatedTodo = TodoModel(
        id: todo.id,
        taskName: todo.taskName,
        taskCompleted: todo.taskCompleted,
        isVisible: false,
        taskDescription: todo.taskDescription,
        taskDate: todo.taskDate,
        taskCategory: todo.taskCategory);

    await _databaseHelper.updateTodo(updatedTodo);

    final index = todoItems.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      todoItems[index] = updatedTodo;
    }
  }

  void updateDropdownValue(String? value, String selectedCategoryValue) {
    selectedCategoryValue = value ?? "";
  }

  void clearAddingTodoFields(
      TextEditingController textController,
      TextEditingController descriptionTextController,
      String selectedCategoryValue,
      DateTime dateTime) {
    textController.clear();
    descriptionTextController.clear();
    selectedCategoryValue = "";
    dateTime = DateTime.now();
  }
}