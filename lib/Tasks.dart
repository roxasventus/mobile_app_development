import 'package:flutter/foundation.dart';

class Tasks extends ChangeNotifier {
  final Map<DateTime, List<String>> _tasks = {};
  final List<String> taskList = [];

  // Method to add tasks to taskList
  void addToTaskList(String task) {
    taskList.add(task);
    notifyListeners();
  }

  // Method to add a task to _tasks on a specific date
  void addTask(DateTime date, String task) {
    _tasks.putIfAbsent(date, () => []).add(task);
    notifyListeners();
  }

  // Getter to retrieve tasks for a specific date
  List<String> getTasks(DateTime date) => _tasks[date] ?? [];
}
