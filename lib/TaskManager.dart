// lib/TaskManager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Task.dart';

class TaskManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자의 userName 가져오기
  Future<String> get currentUserName async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final userDoc = await _firestore.collection('user').doc(user.uid).get();
    return userDoc.data()?['userName'] ?? '';
  }

  // 로그인된 사용자의 모든 작업 실시간 스트림 가져오기
  Stream<List<Task>> fetchTasksStream() async* {
    final userName = await currentUserName;
    yield* _tasksCollection
        .where('userName', isEqualTo: userName)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // 특정 날짜의 작업 가져오기
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final userName = await currentUserName;
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _tasksCollection
          .where('userName', isEqualTo: userName)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching tasks by date: $e');
      return [];
    }
  }

  // 일주일 전의 특정 날짜 작업 가져오기
  Future<List<Task>> getTasksOneWeekAgo(DateTime date) async {
    final userName = await currentUserName;
    try {
      final oneWeekAgo = date.subtract(const Duration(days: 7));
      final startOfDay = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day, 0, 0, 0);
      final endOfDay = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day, 23, 59, 59);

      final snapshot = await _tasksCollection
          .where('userName', isEqualTo: userName)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching tasks from one week ago: $e');
      return [];
    }
  }

  // 새 작업 추가
  Future<void> addTask(Task task) async {
    try {
      final taskData = await task.toMap();
      await _tasksCollection.add(taskData);
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // 작업 완료 상태 토글
  Future<void> toggleTaskCompletion(String id, bool currentStatus) async {
    try {
      await _tasksCollection.doc(id).update({'isCompleted': !currentStatus});
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  // 작업 삭제
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // 작업 순서 업데이트 (필요 시 구현)
  Future<void> updateTaskOrder(String taskId, int newOrder) async {
    try {
      await _tasksCollection.doc(taskId).update({'order': newOrder});
    } catch (e) {
      print('Error updating task order: $e');
    }
  }

// 기타 메서드...
}
