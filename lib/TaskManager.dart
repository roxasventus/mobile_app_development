// lib/TaskManager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Task.dart';

class TaskManager {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  Future<List<Task>> getTasksByDate(DateTime date) async {
    DateTime localStart = DateTime(date.year, date.month, date.day);
    DateTime localEnd = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    DateTime startOfDayUtc = localStart.toUtc();
    DateTime endOfDayUtc = localEnd.toUtc();

    final querySnapshot = await _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDayUtc)
        .where('date', isLessThanOrEqualTo: endOfDayUtc)
        .get();

    return querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
  }

  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': !currentStatus});
  }

  Stream<List<Task>> fetchTasksStream() {
    DateTime nowLocal = DateTime.now();
    DateTime localStart = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    DateTime localEnd = DateTime(nowLocal.year, nowLocal.month, nowLocal.day, 23, 59, 59, 999);

    DateTime startOfDayUtc = localStart.toUtc();
    DateTime endOfDayUtc = localEnd.toUtc();

    return _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDayUtc)
        .where('date', isLessThanOrEqualTo: endOfDayUtc)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }

  // 현재 사용자 이름 가져오기 (임시 'User' -> 실제 로직으로 수정)
  Future<String> get currentUserName async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 로그인 안 된 상태
      return 'Unknown';
    }
    // Firestore에서 userName 필드 가져오기
    final userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    final userName = userDoc.data()?['userName'];

    return userName ?? 'Unknown';
  }

  Future<void> updateTaskOrder(String taskId, int order) async {
    await _tasksCollection.doc(taskId).update({'order': order});
  }

  Future<List<Task>> getTasksSevenDaysAgo(DateTime referenceDate) async {
    DateTime refLocalStart = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    DateTime refStartUtc = refLocalStart.toUtc();
    DateTime sevenDaysAgoUtc = refStartUtc.subtract(const Duration(days: 7));

    DateTime startOfDayUtc = DateTime.utc(sevenDaysAgoUtc.year, sevenDaysAgoUtc.month, sevenDaysAgoUtc.day);
    DateTime endOfDayUtc = DateTime.utc(sevenDaysAgoUtc.year, sevenDaysAgoUtc.month, sevenDaysAgoUtc.day, 23, 59, 59, 999);

    QuerySnapshot querySnapshot = await _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDayUtc)
        .where('date', isLessThanOrEqualTo: endOfDayUtc)
        .get();

    List<Task> tasks = querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
    return tasks;
  }

  Stream<List<Task>> getTasksByDateStream(DateTime date) {
    DateTime localStart = DateTime(date.year, date.month, date.day);
    DateTime localEnd = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    DateTime startOfDayUtc = localStart.toUtc();
    DateTime endOfDayUtc = localEnd.toUtc();

    return _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startOfDayUtc)
        .where('date', isLessThanOrEqualTo: endOfDayUtc)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }
}
