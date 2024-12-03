// lib/TaskProvider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart'; // 추가
import 'task.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  List<Task> _tasks = [];

  List<Task> get allTasks => _tasks;

  List<Task> get unfinishedTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get pastTasks =>
      _tasks.where((task) => task.date.isBefore(DateTime.now())).toList();

  TaskProvider() {
    fetchTasks();
  }

  // Firestore에서 모든 작업 가져오기 (실시간)
  Future<void> fetchTasks() async {
    try {
      _tasksCollection.snapshots().listen((snapshot) {
        _tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        notifyListeners();
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  // 새 작업 추가
  Future<void> addTask(Task task) async {
    try {
      await _tasksCollection.add(task.toMap());
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // 작업 상태 토글
  Future<void> toggleTaskCompletion(String id) async {
    try {
      Task? task = _tasks.firstWhereOrNull((task) => task.id == id);
      if (task != null) {
        await _tasksCollection.doc(id).update({'isCompleted': !task.isCompleted});
      } else {
        print('Task with id $id not found.');
        // 추가적인 처리 (예: 사용자에게 오류 메시지 표시)
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  // 특정 날짜의 작업 가져오기
  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) => isSameDate(task.date, date)).toList();
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 작업 삭제
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}
