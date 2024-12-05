// lib/TaskManager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Task.dart';

class TaskManager {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  // 특정 날짜의 할 일 가져오기 (로컬날짜 -> UTC 변환 후 쿼리)
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

  // 할 일 추가
  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());
  }

  // 할 일 삭제
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // 할 일 완료 상태 토글
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': !currentStatus});
  }

  // 오늘의 할 일 실시간 스트림
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

  // 현재 사용자 이름 가져오기
  Future<String> get currentUserName async {
    // 인증 로직이 실제로 구현되어 있어야 함
    return 'User'; // 임시로 'User' 반환
  }

  // 할 일 순서 업데이트
  Future<void> updateTaskOrder(String taskId, int order) async {
    await _tasksCollection.doc(taskId).update({'order': order});
  }

  // 7일 전의 할 일 가져오기 (referenceDate로부터 정확히 7일 전)
  Future<List<Task>> getTasksSevenDaysAgo(DateTime referenceDate) async {
    // referenceDate를 로컬로 가정, 이를 UTC로 변환
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

  // 특정 날짜의 할 일 실시간 스트림 가져오기 (Stream)
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
