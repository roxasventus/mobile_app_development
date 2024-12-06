import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Task.dart';

class TaskManager {
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  Future<String> get currentUserId async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }
    return user.uid;
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final userId = await currentUserId;
    DateTime startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    DateTime endOfDay =
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc();

    final querySnapshot = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
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

  Stream<List<Task>> fetchTasksStream() async* {
    final userId = await currentUserId;
    DateTime startOfDay =
    DateTime.now().toUtc().subtract(const Duration(hours: 9));
    DateTime endOfDay = startOfDay.add(const Duration(hours: 24));

    yield* _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }

  Future<void> updateTaskOrder(String taskId, int order) async {
    await _tasksCollection.doc(taskId).update({'order': order});
  }

  Future<List<Task>> getTasksSevenDaysAgo(DateTime referenceDate) async {
    final userId = await currentUserId;
    DateTime sevenDaysAgo = referenceDate.subtract(const Duration(days: 7));
    DateTime startOfDay =
    DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day).toUtc();
    DateTime endOfDay = DateTime(
      sevenDaysAgo.year,
      sevenDaysAgo.month,
      sevenDaysAgo.day,
      23,
      59,
      59,
      999,
    ).toUtc();

    final querySnapshot = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    return querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
  }

  // New Method: Get All Incomplete Tasks
  Future<List<Task>> getIncompleteTasks() async {
    final userId = await currentUserId;

    final querySnapshot = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();

    return querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
  }

  Stream<List<Task>> getIncompleteTasksStream() {
    return _tasksCollection
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }
}
