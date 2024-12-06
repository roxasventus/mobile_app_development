import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Task.dart';

class TaskManager {
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  // 현재 로그인된 사용자 ID 가져오기
  Future<String> get currentUserId async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }
    return user.uid;
  }

  // 특정 날짜의 작업 가져오기
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

  // 작업 추가하기
  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());
  }

  // 작업 삭제하기
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // 작업 완료 상태 토글
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': !currentStatus});
  }

  // 오늘 날짜의 작업 스트림 가져오기
  Stream<List<Task>> fetchTasksStream() async* {
    final userId = await currentUserId;
    DateTime startOfDay =
    DateTime.now().toUtc().subtract(const Duration(hours: 9)); // UTC 기준
    DateTime endOfDay = startOfDay.add(const Duration(hours: 24));

    yield* _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }

  // 작업 순서 업데이트
  Future<void> updateTaskOrder(String taskId, int order) async {
    await _tasksCollection.doc(taskId).update({'order': order});
  }

  // 기준 날짜로부터 7일 전 작업 가져오기
  Future<List<Task>> getTasksSevenDaysAgo(DateTime referenceDate) async {
    final userId = await currentUserId;
    DateTime sevenDaysAgo = referenceDate.subtract(const Duration(days: 7));
    DateTime startOfDay =
    DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day)
        .toUtc();
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

  // 모든 미완료 작업 가져오기
  Future<List<Task>> getIncompleteTasks() async {
    final userId = await currentUserId;

    final querySnapshot = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();

    return querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
  }

  // 모든 미완료 작업 스트림 가져오기
  Stream<List<Task>> getIncompleteTasksStream() async* {
    final userId = await currentUserId;

    yield* _tasksCollection
        .where('userId', isEqualTo: userId) // 사용자 필터 추가
        .where('isCompleted', isEqualTo: false) // 미완료 작업 필터
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }

  Stream<List<Task>> getTasksByDateStream(DateTime date) async* {
    final userId = await currentUserId;
    DateTime startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    DateTime endOfDay =
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc();

    yield* _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList());
  }
}
