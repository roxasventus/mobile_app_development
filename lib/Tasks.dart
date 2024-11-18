import 'package:flutter/foundation.dart';

class Tasks extends ChangeNotifier {
  final Map<DateTime, List<String>> _tasks = {};
  final List<String> taskList = [];
  final List<String> unfinishedtaskList = [];
  final List<String> pasttaskList = [];

  // Method to add tasks to taskList
  void addToTaskList(String task) {
    taskList.add(task);
    notifyListeners();
  }

  void addToUnfinishedTaskList(String task) {
    unfinishedtaskList.add(task);
    notifyListeners();
  }

  void addToPastTaskList(String task) {
    pasttaskList.add(task);
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
